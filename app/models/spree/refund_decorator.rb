module Spree::Retail
  module RefundDecorator
    delegate :pos_order_id, to: :payment
    delegate :pos_refunded, to: :reimbursement

    def perform!
      if pos_refunded?
        update_order
        return true
      else
        super
      end
    end
  end
end

Spree::Refund.prepend Spree::Retail::RefundDecorator
