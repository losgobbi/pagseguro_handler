class PurchasesController < ApplicationController
  # TODO, we have to handle this in a secure manner
  skip_before_action :verify_authenticity_token

  # GET /purchases/new
  def new
    payment = PagSeguro::PaymentRequest.new
    purchase = Purchase.create(buyer_name: params[:buyer_name], buyer_email: params[:buyer_email])
    item = PurchaseItem.create(sku_id: params[:sku_id], sku_description: params[:sku_desc], sku_value: params[:sku_value])

    # FIXME store id should be a integer
    purchase.store_id = "store_id_0" + params[:storeId].to_s

    logger.debug "Creating a new purchase " + purchase.inspect + " with item " + item.inspect

    payment.reference = purchase.id
    //payment.primary_receiver = <target_email>
    payment.sender = {
        name:  purchase.buyer_name,
        email: purchase.buyer_email,
    }
    payment.items << {
        id: item.sku_id,
        description: item.sku_description,
        amount: item.sku_value
    }
    payment.extra_params << { shippingAddressRequired: false }

    purchase.purchase_item << item

    logger.debug "Payment " + payment.inspect
    response = payment.register

    if response.errors.any?
      purchase.payment_errors = response.errors.to_s
      purchase.save
      render json: {error: response.errors, status: 404}.to_json
    else
      logger.debug "User " + purchase.buyer_email + " have R$" + item.sku_value.to_f.to_s + " of pending credits"
      purchase.checkout_code = response.code.to_s
      purchase.save
      render json: {code: response.code, status: 200}.to_json
    end
  end
end
