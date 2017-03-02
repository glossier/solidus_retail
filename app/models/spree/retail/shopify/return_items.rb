module Spree
  module Retail
    module Shopify
      module ReturnItems
        extend self

        def all_for(order, shopify_refund_line_items)
          return_items = []
          shopify_refund_line_items.each do |rli|
            inventory_unit = order.all_inventory_units.detect { |iu| iu.variant.pos_variant_id == rli.line_item.variant_id.to_s }

            # This probably means that it's a bundled product
            if inventory_unit.nil?
              bundle_variants = variant_skus_for_bundle(rli.line_item)
              inventory_units = order.all_inventory_units.select { |iu| bundle_variants.include?(iu.variant.sku) }

              inventory_units.each do |iu|
                return_items << create(iu)
              end
            else
              return_items << create(inventory_unit)
            end
          end

          return_items
        end

        def create(inventory_unit)
          Spree::ReturnItem.create(
            inventory_unit: inventory_unit,
            preferred_reimbursement_type: reimbursement_type,
            refund_amount_calculator: default_refund_calculator
          ).tap(&:accept!)
        end

        private

        def reimbursement_type
          Spree::ReimbursementType.first
        end

        def default_refund_calculator
          Spree::Retail::Calculator::Returns::DefaultRefundAmount
        end

        def variant_skus_for_bundle(item)
          variants = []
          item.sku.split('/').drop(1).each do |v|
            variants << v.gsub("-SET", "")
          end
          variants
        end
      end
    end
  end
end
