require 'net/https'
require 'active_support/core_ext/hash'
require 'json'

require 'aws/dynamohelper'
require 'pagseguro/pagsegurostate'

class NotificationsController < ApplicationController
  skip_before_filter :verify_authenticity_token, only: :create

  def create

    # Transaction.find_by_notification_code is not working on sdk2.5.0, build it manually
    token = PagSeguro.configuration.token
    email = PagSeguro.configuration.email
    notification_code = params[:notificationCode].gsub('-', '')

    # TODO fetch from initializer
    notification_url = "https://ws.pagseguro.uol.com.br/v2/transactions/notifications/"
    url = notification_url + notification_code
    url += "?email=" + email
    url += "&token=" + token

    uri = URI(url)

    # TODO, handle errors
    response = Net::HTTP.get(uri)
    notification_info = JSON.parse(Hash.from_xml(response).to_json)

    code = notification_info["transaction"]["code"]

    logger.debug "Notification received " + code.inspect

    notification = Notification.where(transaction_code: code).first
    if notification.nil?
      logger.debug "created a new notification instance"

      notification = Notification.new
      notification.transaction_code = code
      notification.transaction_date = notification_info["transaction"]["date"]
      notification.transaction_sender_email = notification_info["transaction"]["sender"]["email"]
      status = notification_info["transaction"]["status"].to_i
      notification.transaction_payment_type = notification_info["transaction"]["paymentMethod"]["type"]
      notification.transaction_amount = notification_info["transaction"]["grossAmount"]
      notification.transaction_feeAmount = notification_info["transaction"]["feeAmount"]

      pagstate = PagSeguroHelper::PagSeguroState.new(PagSeguroHelper::PagSeguroState::STATE_INICIO, status)
    else
      logger.debug "updating a notification instance " + notification.inspect

      status = notification_info["transaction"]["status"].to_i
      pagstate = PagSeguroHelper::PagSeguroState.new(notification.transaction_status, status)
    end

    notification.transaction_last_event_date = notification_info["transaction"]["lastEventDate"]
    notification.transaction_reference = notification_info["transaction"]["reference"].to_i

    purchase = Purchase.find(notification.transaction_reference)
    logger.debug "Updating credits at dynamodb for pagseguro user " + notification.transaction_sender_email +
                     " purchase " + purchase.inspect
    logger.debug "PagSeguro state " + pagstate.to_s

    dyn = AwsHelper::DynamoHelper.new
    if pagstate.pending?
      logger.debug "updating pending value"
      dyn.user_add_credits(purchase.store_id, purchase.buyer_email, purchase.purchase_item.first.sku_value.to_f, true)
    elsif pagstate.credit?
      logger.debug "update credit without pending"
      dyn.user_add_credits(purchase.store_id, purchase.buyer_email, purchase.purchase_item.first.sku_value.to_f, false)
    elsif pagstate.checkout_pending?
      logger.debug "checkout pending"
      dyn.user_checkout_pending_credits(purchase.store_id, purchase.buyer_email, purchase.purchase_item.first.sku_value.to_f)
    elsif pagstate.canceled?
      logger.debug "remove pending"
      dyn.user_remove_pending_credits(purchase.store_id, purchase.buyer_email, purchase.purchase_item.first.sku_value.to_f)
    else
      logger.debug "unknown state " + pagstate.inspect
    end

    # update fields related to each state
    case pagstate.current_state
      when PagSeguroHelper::PagSeguroState::STATE_CANCELADA
        notification.transaction_cancellation_source = notification_info["transaction"]["cancellationSource"]
      when PagSeguroHelper::PagSeguroState::STATE_PAGA, PagSeguroHelper::PagSeguroState::STATE_DISPONIVEL,
          PagSeguroHelper::PagSeguroState::STATE_EM_DISPUTA, PagSeguroHelper::PagSeguroState::STATE_DEVOLVIDA
        notification.transaction_escrow_date = notification_info["transaction"]["escrowEndDate"]
    end

    # update current state
    notification.transaction_status = status
    notification.save

    render nothing: true, status: 200
  end
end