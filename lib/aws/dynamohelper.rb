require 'aws-sdk'
require 'logger'

module AwsHelper
  class DynamoHelper
    def user_add_credits(store_id, buyer, value, pending)
      Rails.logger.debug "User_add_credits " + buyer + " R$ " + value.to_s + " pending " + pending.to_s
      dynamodb = Aws::DynamoDB::Client.new
      begin
        if pending
          update_exp = "SET info.pending_credit = info.pending_credit + :val"
        else
          update_exp = "SET info.credit = info.credit + :val"
        end
        response = dynamodb.
            update_item(
                {
                    table_name: "clients",
                    key: {
                        "store_id": store_id,
                        "user_id": buyer,
                    },
                    update_expression: update_exp,
                    expression_attribute_values: {
                        ":val": value
                    },
                })
        Rails.logger.error "response.items " + response.inspect
      rescue Aws::DynamoDB::Errors::ServiceError => serviceErr
        Rails.logger.error "user_add_credits:ServiceError " + serviceErr.inspect
      rescue Aws::DynamoDB::Errors::ConditionalCheckFailedException => condError
        Rails.logger.error "user_add_credits:ConditionalCheckFailedException " + condError.inspect
      rescue Aws::DynamoDB::Errors::ResourceNotFoundException => resError
        Rails.logger.error "user_add_credits:ResourceNotFoundException " + resError.inspect
      end
    end

    def user_checkout_pending_credits(store_id, buyer, value)
      Rails.logger.debug "User_checkout_pending_credits " + buyer
      dynamodb = Aws::DynamoDB::Client.new
      begin
        response = dynamodb.
            update_item(
                {
                    table_name: "clients",
                    key: {
                        "store_id": store_id,
                        "user_id": buyer,
                    },
                    update_expression: "SET info.credit = info.credit + :val, info.pending_credit = info.pending_credit - :val",
                    expression_attribute_values: {
                        ":val": value
                    },
                })
        Rails.logger.error "response.items " + response.inspect
      rescue Aws::DynamoDB::Errors::ServiceError => serviceErr
        Rails.logger.error "user_checkout_pending_credits:ServiceError " + serviceErr.inspect
      rescue Aws::DynamoDB::Errors::ConditionalCheckFailedException => condError
        Rails.logger.error "user_checkout_pending_credits:ConditionalCheckFailedException " + condError.inspect
      rescue Aws::DynamoDB::Errors::ResourceNotFoundException => resError
        Rails.logger.error "user_checkout_pending_credits:ResourceNotFoundException " + resError.inspect
      end
    end

    def user_remove_pending_credits(store_id, buyer, value)
      Rails.logger.debug "User_remove_pending credits " + buyer + " R$ " + value.to_s
      dynamodb = Aws::DynamoDB::Client.new
      begin
        response = dynamodb.
            update_item(
                {
                    table_name: "clients",
                    key: {
                        "store_id": store_id,
                        "user_id": buyer,
                    },
                    update_expression: "SET info.pending_credit = info.pending_credit - :val",
                    expression_attribute_values: {
                        ":val": value
                    },
                })
        Rails.logger.error "response.items " + response.inspect
      rescue Aws::DynamoDB::Errors::ServiceError => serviceErr
        Rails.logger.error "user_remove_pending_credits:ServiceError " + serviceErr.inspect
      rescue Aws::DynamoDB::Errors::ConditionalCheckFailedException => condError
        Rails.logger.error "user_remove_pending_credits:ConditionalCheckFailedException " + condError.inspect
      rescue Aws::DynamoDB::Errors::ResourceNotFoundException => resError
        Rails.logger.error "user_remove_pending_credits:ResourceNotFoundException " + resError.inspect
      end
    end
  end
end