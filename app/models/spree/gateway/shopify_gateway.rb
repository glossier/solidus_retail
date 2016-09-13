require 'active_merchant/billing/gateways/shopify'

module Spree
  class Gateway::ShopifyGateway < Gateway
    class PaymentNotFoundError < ActiveRecord::RecordNotFound; end

    preference :api_key, :string
    preference :password, :string
    preference :shop_name, :string

    def provider_class
      ActiveMerchant::Billing::ShopifyGateway
    end

    def method_type
      'shopify'
    end

    def credit(money, transaction_id, gateway_options)
      refund = gateway_options[:originator]
      options = { order_id: refund.pos_order_id, reason: refund.reason.name }
      provider.refund(money, transaction_id, options)
    end

    def void(transaction_id, _)
      unless payment = find_payment_for_transaction_id(transaction_id)
        raise PaymentNotFoundError,
          "A payment matching the transaction ID ##{transaction_id} could not be found."
      end

      provider.void(transaction_id, order_id: payment.pos_order_id)
    end

    def cancel(_transaction_id)
      raise NotImplementedError
    end

    def purchase(_money, _creditcard, _gateway_options)
      raise NotImplementedError
    end

    def authorize(_money, _creditcard, _gateway_options)
      raise NotImplementedError
    end

    def capture(_money, _response_code, _gateway_options)
      raise NotImplementedError
    end

    def create_profile(_payment)
      raise NotImplementedError
    end

    private

    def find_payment_for_transaction_id(id)
      payments.find_by(response_code: id)
    end
  end
end
