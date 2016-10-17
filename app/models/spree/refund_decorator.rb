module Spree::Retail
  module RefundDecorator
    delegate :pos_order_id, to: :payment
    delegate :pos_refunded, :pos_refunded?, to: :reimbursement

    def perform!
      return super if reimbursement.nil? || !pos_refunded?

      return_all_inventory_unit!(reimbursement)
      try_set_order_to_return!(reimbursement)
      update_order

      true
    end

    private

    def return_all_inventory_unit!(reimbursement)
      reimbursement.return_items.each do |return_item|
        return_item.inventory_unit.return!
      end
    end

    def try_set_order_to_return!(reimbursement)
      reimbursement.order.return!
    end
  end
end

Spree::Refund.prepend Spree::Retail::RefundDecorator
