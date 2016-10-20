module Spree::Retail
  module ReimbursementDecorator
    def pos_refunded!
      update_attribute(:pos_refunded, true)
    end

    def return_order
      order.return
    end
  end
end

Spree::Reimbursement.prepend Spree::Retail::ReimbursementDecorator
