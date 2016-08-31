module Spree
  module Retail
    class ShopifyRefunder
      def initialize(credited_money, transaction_id, options)
        @refund_reason = options[:reason]
        @order_id = options[:order_id]
        @credited_money = BigDecimal.new(credited_money)
        @transaction = ShopifyAPI::Transaction.find(transaction_id, params: { order_id: order_id })
      end

      def perform
        raise ActiveMerchant::Billing::ShopifyGateway::TransactionNotFoundError if transaction.nil?

        if full_refund? || partial_refund?
          perform_refund_on_shopify
        else
          raise ActiveMerchant::Billing::ShopifyGateway::CreditedAmountBiggerThanTransaction
        end
      end

      private

      def perform_refund_on_shopify
        refund = ShopifyAPI::Refund.create(order_id: order_id,
                                           shipping: { amount: 0 },
                                           note: refund_reason,
                                           notify: false,
                                           restock: false,
                                           transactions: [{
                                             parent_id: transaction.id,
                                             amount: amount_to_dollars(credited_money),
                                             gateway: 'shopify-payments',
                                             kind: 'refund'
                                           }])

        success = refund.errors == []
        if success || refund.errors.messages.empty?
          ActiveMerchant::Billing::Response.new(true, nil)
        else
          ActiveMerchant::Billing::Response.new(success, refund.errors.messages)
        end
      end

      def full_refund?
        credited_money == amount_to_cents(transaction.amount)
      end

      def partial_refund?
        credited_money < amount_to_cents(transaction.amount)
      end

      def amount_to_cents(amount)
        BigDecimal.new(amount) * 100
      end

      def amount_to_dollars(amount)
        BigDecimal.new(amount) / 100
      end

      attr_accessor :credited_money, :refund_reason, :transaction, :order_id
    end
  end
end
