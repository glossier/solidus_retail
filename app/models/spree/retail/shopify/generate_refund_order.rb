module Spree
  module Retail
    module Shopify
      class GenerateRefundOrder
        def initialize(shopify_refund)
          @shopify_refund = shopify_refund
        end

        def process
          order = find_order(shopify_refund)

          return_items = []
          shopify_refund.refund_line_items.each do |rli|
            inventory_unit = find_inventory_by_shopify_variant_id(order, rli.line_item.variant_id)
            return_items << create_return_item(inventory_unit)
          end

          create_return_authorization(order, return_items)
          customer_return = create_customer_return(return_items)
          create_reimbursement(customer_return)
        end

        private

        def find_inventory_by_shopify_variant_id(order, shopify_variant_id)
          order.shipments.first.inventory_units.find { |unit| unit.variant.pos_variant_id.to_i == shopify_variant_id.to_i }
        end

        def create_return_item(inventory_unit)
          return_item = Spree::ReturnItem.create(
            inventory_unit: inventory_unit,
            preferred_reimbursement_type: reimbursement_type
          )
          return_item.accept!
          return_item
        end

        def create_return_authorization(order, return_items)
          Spree::ReturnAuthorization.create(
            order: order,
            stock_location: stock_location_to_refund,
            return_reason_id: return_reason.id,
            memo: "Automated refund made by Shopify",
            return_items: return_items
          )
        end

        def create_customer_return(return_items)
          Spree::CustomerReturn.create(
            stock_location: stock_location_to_refund,
            return_items: return_items
          )
        end

        def create_reimbursement(customer_return)
          reimbursement = Spree::Reimbursement.build_from_customer_return(customer_return)
          reimbursement.save
          reimbursement.perform!
        end

        attr_reader :shopify_refund

        def find_order(shopify_refund)
          Spree::Order.find_by(pos_order_id: order_id_for(shopify_refund))
        end

        def order_id_for(shopify_refund)
          shopify_refund.prefix_options[:order_id]
        end

        def return_reason
          Spree::ReturnReason.first
        end

        def stock_location_to_refund
          Spree::StockLocation.first
        end

        def reimbursement_type
          Spree::ReimbursementType.first
        end
      end
    end
  end
end
