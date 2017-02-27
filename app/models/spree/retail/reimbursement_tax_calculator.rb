module Spree
  module Retail
    class ReimbursementTaxCalculator
      class << self
        def call(reimbursement)
          reimbursement.return_items.includes(:inventory_unit).each do |return_item|
            set_tax!(return_item)
          end
        end

        private

        def set_tax!(return_item)
          # The Shopify taxes are not imported has taxes in Solidus. We create
          # an adjustment for every tax type. When we need to calculate the tax
          # for the refund process, we need to retrieve those adjustments and
          # count them has taxes so we can refund the proper amount to the client.
          adjustment_amount = return_item.inventory_unit.line_item.adjustments.map(&:amount).inject(:+)

          # For sakes of clarity
          additional_tax_total = adjustment_amount

          return_item.update_attributes!({
            additional_tax_total: additional_tax_total
          })
        end
      end
    end
  end
end
