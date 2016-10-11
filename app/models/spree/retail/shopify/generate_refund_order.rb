module Spree
  module Retail
    module Shopify
      class GenerateRefundOrder
        def initialize(shopify_refund)
          @shopify_refund = shopify_refund
        end

        def process
          spree_refund = create_refund
          spree_refund.payment = find_payment(shopify_refund)
          spree_refund.transaction_id = shopify_refund.transactions.first.id
          spree_refund.created_at = shopify_refund.created_at
          spree_refund.amount = refund_amount_for(shopify_refund)
          spree_refund.refund_reason_id = refund_reason.id
          spree_refund.save!

          shopify_refund
        rescue => e
          Rails.logger.error("shopify_refund id ##{shopify_refund.try(:id)}: #{e}")
        end

        private

        attr_reader :shopify_refund

        def create_refund
          Spree::Refund.new
        end

        def find_order(shopify_refund)
          Spree::Order.find_by(pos_order_id: order_id_for(shopify_refund))
        end

        def find_payment(shopify_refund)
          # NOTE: There will always only be one payment for a Shopify order
          spree_order = find_order(shopify_refund)
          spree_order.payments.first
        end

        def order_id_for(shopify_refund)
          shopify_refund.prefix_options[:order_id]
        end

        def refund_amount_for(shopify_refund)
          # Get all the amount of all the transaction,
          # Convert from string to float,
          # Sum them up.
          shopify_refund.transactions.map(&:amount).map(&:to_f).inject(:+)
        end

        def refund_reason
          Spree::RefundReason.first
        end
      end
    end
  end
end
