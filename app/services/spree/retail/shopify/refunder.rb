module Spree::Retail
  module Shopify
    class Refunder
      def initialize(credited_money:, transaction:, refunder_interface: nil, can_issue_refund_policy_klass: nil, **options)
        @credited_money = BigDecimal.new(credited_money)
        @transaction = transaction
        @refund_reason = options[:reason]

        # FIXME: HOOOOOOORJ This is abominable
        @order_id = transaction.prefix_options[:order_id]

        @refunder_interface = refunder_interface || default_refunder_interface
        @can_issue_refund_policy_klass = can_issue_refund_policy_klass || Spree::Retail::Shopify::CanIssueRefundPolicy
      end

      def perform
        perform_refund_in_shopify if can_issue_refund?
      end

      private

      attr_accessor :can_issue_refund_policy_klass, :credited_money,
        :refund_reason, :transaction, :order_id, :transaction_interface,
        :refunder_interface

      def can_issue_refund?
        can_issue_refund_policy.allowed?
      end

      def can_issue_refund_policy
        can_issue_refund_policy_klass.new(transaction: transaction,
                                          amount_to_credit: credited_money)
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
    end
  end
end
