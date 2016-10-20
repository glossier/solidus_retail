module Spree::Retail
  module RefundDecorator
    delegate :pos_order_id, to: :payment
    delegate :pos_refunded, :pos_refunded?,
             :return_order, to: :reimbursement, allow_nil: true

    def perform!
      return super if !pos_refunded?

      return_all_inventory_unit!(reimbursement)
      return_order
      update_order

      true
    end

    private

    def return_all_inventory_unit!(reimbursement)
      reimbursement.return_items.each do |return_item|
        return_item.inventory_unit.return!
      end
    end
  end
end

Spree::Refund.prepend Spree::Retail::RefundDecorator
