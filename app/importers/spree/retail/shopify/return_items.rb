module Spree
  module Retail
    module Shopify
      class ReturnItems
        def initialize(spree_order, shopify_refund)
          @spree_order = spree_order
          @shopify_refund = shopify_refund
        end

        def all
          return_items = []
          shopify_refund.refund_line_items.each do |rli|
            inventory_unit = find_inventory_by_shopify_variant_id(spree_order, rli.line_item.variant_id)
            return_items << create_return_item(inventory_unit)
          end

          return_items
        end

        def create(inventory_unit)
          Spree::ReturnItem.create(
            inventory_unit: inventory_unit,
            preferred_reimbursement_type: reimbursement_type
          ).tap(&:accept!)
        end

        private

        attr_accessor :spree_order, :shopify_refund

        def find_inventory_by_shopify_variant_id(spree_order, shopify_variant_id)
          spree_order.shipments.first.inventory_units.find { |unit| unit.variant.pos_variant_id.to_i == shopify_variant_id.to_i }
        end

        def reimbursement_type
          Spree::ReimbursementType.first
        end
      end
    end
  end
end
