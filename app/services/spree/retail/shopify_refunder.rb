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
        perform_refund_in_shopify if can_issue_refund?
      end

      private

      attr_accessor :credited_money, :refund_reason, :transaction, :order_id,
                     :transaction_interface, :refunder_interface

      def can_issue_refund?
        CanIssueRefundPolicy.new(transaction: transaction,
                                 amount_to_credit: credited_money).allowed?
      end

      def perform_refund_in_shopify
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

      def amount_to_dollars(amount)
        BigDecimal.new(amount) / 100
      end

      def default_refunder_interface
        ShopifyAPI::Refund
      end

      def default_transaction_interface
        ShopifyAPI::Transaction
      end

      class CanIssueRefundPolicy
        def initialize(transaction:, amount_to_credit:)
          @amount_to_credit, @transaction = amount_to_credit, transaction
        end

        def allowed?
          raise Spree::Retail::Shopify::TransactionNotFoundError if transaction_not_found?
          raise Spree::Retail::Shopify::CreditedAmountBiggerThanTransaction if transaction_too_big?

          true
        end

        private

        attr_reader :amount_to_credit, :transaction

        def transaction_not_found?
          transaction.nil?
        end

        def transaction_too_big?
          !(full_refund? || partial_refund?)
        end

        def full_refund?
          amount_to_credit == amount_to_cents(transaction.amount)
        end

        def partial_refund?
          amount_to_credit < amount_to_cents(transaction.amount)
        end

        def amount_to_cents(amount)
          BigDecimal.new(amount) * 100
        end
      end
    end
  end
end
