module Spree
  module Retail
    module Shopify
      class Refunder
        def initialize(credited_money:, transaction:, refund_factory: nil, refund_policy_klass: nil, **options)
          @credited_money = BigDecimal.new(credited_money)
          @transaction = transaction
          @refund_reason = options[:reason]
          @order_id = transaction.order_id

          @refund_factory = refund_factory || default_refund_factory
          @refund_policy_klass = refund_policy_klass || default_refund_policy_klass
        end

        def perform
          perform_refund_in_shopify if can_issue_refund?
        end

        private

        attr_accessor :refund_policy_klass, :credited_money, :refund_reason,
          :transaction, :order_id, :refund_factory

        def can_issue_refund?
          refund_policy.allowed?
        end

        def refund_policy
          refund_policy_klass.new(transaction: transaction,
                                  amount_to_credit: credited_money)
        end

        def perform_refund_in_shopify
          refund_factory.create(order_id: order_id,
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

        def default_refund_factory
          ShopifyAPI::Refund
        end

        def default_refund_policy_klass
          Spree::Retail::Shopify::CanIssueRefundPolicy
        end
      end
    end
  end
end
