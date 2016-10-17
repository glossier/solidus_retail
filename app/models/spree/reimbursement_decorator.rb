module Spree::Retail
  module ReimbursementDecorator
    def pos_refunded!
      update_attribute(:pos_refunded, true)
    end

    def try_set_order_to_return!
      order.return!
    end
  end
end

Spree::Reimbursement.prepend Spree::Retail::ReimbursementDecorator
