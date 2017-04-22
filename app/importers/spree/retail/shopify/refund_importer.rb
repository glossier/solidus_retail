module Spree
  module Retail
    module Shopify
      class RefundImporter
        include PresenterHelper

        def initialize(shopify_refund, callback:, logger: RefundLogger)
          @shopify_refund = shopify_refund
          @spree_order = find_spree_order_for(shopify_refund)
          @callback = callback
          @logger = logger.new(shopify_refund)
        end

        def perform
          unless refund_already_exists?(spree_order)
            Spree::Retail::Shopify::Refund.create(spree_order, return_items)
            sync_taxes(shopify_refund.refund_line_items, spree_order)
          end

          callback.success_case
        rescue => e
          logger.exception_raised(e)
          callback.failure_case
        end

        private

        attr_accessor :shopify_refund, :spree_order, :callback, :logger

        def refund_already_exists?(spree_order)
          exists = spree_order.returned?
          logger.already_exists(spree_order) if exists

          exists
        end

        def return_items
          refund_line_items = shopify_refund.refund_line_items
          @_return_items ||= ReturnItems.all_for(presented_order, refund_line_items)
        end

        def find_spree_order_for(shopify_refund)
          Spree::Order.find_by(pos_order_id: spree_order_id_for(shopify_refund))
        end

        def spree_order_id_for(shopify_refund)
          shopify_refund.prefix_options[:order_id]
        end

        def presented_order
          present(spree_order, :order)
        end

        # NOTE: When adding a refund to an order, the adjustments disappear.
        # The way we are syncing the taxes from Shopify to Solidus is by making
        # adjustments. In that scenario, we have to re-add the adjustments.
        def sync_taxes(refund_line_items, spree_order)
          refund_line_items.each do |line|
            shopify_line_item = line.line_item
            spree_line_item = spree_order.line_items.detect{ |li| li.variant.sku == shopify_line_item.sku }
            if spree_line_item.present?
              spree_line_item.adjustments = build_adjustments(shopify_line_item, spree_line_item, spree_order)
              spree_line_item.save
            end
          end
        end

        def build_adjustments(shopify_line_item, spree_line_item, order)
          adjustments = []
          shopify_line_item.tax_lines.each do |tax|
            adjustment = spree_line_item.adjustments.tax.build
            adjustment.amount = tax.price
            adjustment.label = tax.title
            adjustment.order = order
            adjustments << adjustment
          end

          adjustments
        end
      end
    end
  end
end
