require_dependency 'spree/returns_calculator'

module Spree
  module Retail
    module Calculator
      module Returns
        class DefaultRefundAmount < ReturnsCalculator
          def compute(return_item)
            return 0.0.to_d if return_item.part_of_exchange?
            if return_item.inventory_unit.line_item.parts.any?
              return_item.inventory_unit.line_item.amount * percentage_of_line_item_for_bundles(return_item.inventory_unit)
            else
              weighted_order_adjustment_amount(return_item.inventory_unit) + weighted_line_item_amount(return_item.inventory_unit)
            end
          end

          private

          def weighted_order_adjustment_amount(inventory_unit)
            inventory_unit.order.adjustments.eligible.non_tax.sum(:amount) * percentage_of_order_total(inventory_unit)
          end

          def weighted_line_item_amount(inventory_unit)
            inventory_unit.line_item.discounted_amount * percentage_of_line_item(inventory_unit)
          end

          def percentage_of_order_total(inventory_unit)
            return 0.0 if inventory_unit.order.discounted_item_amount.zero?
            weighted_line_item_amount(inventory_unit) / inventory_unit.order.discounted_item_amount
          end

          def percentage_of_line_item(inventory_unit)
            1 / BigDecimal.new(inventory_unit.line_item.quantity)
          end

          def percentage_of_line_item_for_bundles(inventory_unit)
            inventory_unit.variant.price / BigDecimal.new(inventory_unit.line_item.amount)
          end
          end
        end
      end
    end
  end
