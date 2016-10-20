module Spree
  module Retail
    module Shopify
      module ReturnItems
        extend self

        def all_for(order, shopify_refund_line_items)
          return_items = []
          shopify_refund_line_items.each do |rli|
              inventory_unit = order.all_inventory_units.find_by(pos_variant_id: rli.line_item.variant_id)
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

        def reimbursement_type
          Spree::ReimbursementType.first
        end
      end
    end
  end
end
