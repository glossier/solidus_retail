require_dependency 'spree/retail/shopify'

module Spree
  module Retail
    module Shopify
      class CanIssueRefundPolicy
        def initialize(transaction:, amount_to_credit:)
          @amount_to_credit = amount_to_credit
          @transaction = transaction
        end

        def allowed?
          raise TransactionNotFoundError if transaction_not_found?
          raise CreditedAmountBiggerThanTransaction if transaction_too_big?

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
