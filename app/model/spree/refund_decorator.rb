module Spree
  module RefundDecorator
    delegate :pos_order_id, to: :payment
  end
end

Spree::Refund.prepend Spree::RefundDecorator
