module Spree::Retail
  module Shopify
    class Voider
      def initialize(transaction_id, order_id, transaction_interface = nil, refunder_class = nil)
        @order_id = order_id
        @refunder_class = refunder_class || default_refunder_class
        @transaction_interface = transaction_interface || default_transaction_interface
        @transaction = transaction_interface.find(transaction_id, params: { order_id: order_id })
      end

      def perform
        raise Shopify::TransactionNotFoundError if transaction.nil?

        options = { order_id: order_id, reason: 'Payment voided' }
        full_amount_to_cents = BigDecimal.new(transaction.amount) * 100
        refunder = refunder_class.new(full_amount_to_cents, transaction.id, options)
        refunder.perform
      end

      private

      attr_reader :transaction, :order_id, :transaction_interface, :refunder_class

      def default_refunder_class
        Spree::Retail::ShopifyRefunder
      end

      def default_transaction_interface
        ShopifyAPI::Transaction
      end
    end
  end
end
