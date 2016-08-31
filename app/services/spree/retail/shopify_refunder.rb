module Spree
  module Retail
    class ShopifyRefunder
      def initialize(credited_money, transaction_id, options, transaction_interface = nil, refunder_interface = nil)
        @refund_reason = options[:reason]
        @order_id = options[:order_id]
        @credited_money = BigDecimal.new(credited_money)
        @transaction_interface = transaction_interface || default_transaction_interface
        @refunder_interface = refunder_interface || default_refunder_interface
        @transaction = @transaction_interface.find(transaction_id, params: { order_id: order_id })
      end

      def perform
        raise Shopify::TransactionNotFoundError if transaction.nil?

        if full_refund? || partial_refund?
          perform_refund_on_shopify
        else
          raise Shopify::CreditedAmountBiggerThanTransaction
        end
      end

      private

      attr_accessor :credited_money, :refund_reason, :transaction, :order_id,
                     :transaction_interface, :refunder_interface

      def perform_refund_on_shopify
        refunder_interface.create(order_id: order_id,
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

      def default_refunder_interface
        ShopifyAPI::Refund
      end

      def default_transaction_interface
        ShopifyAPI::Transaction
      end
    end
  end
end
