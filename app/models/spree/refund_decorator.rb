module Spree::Retail
  module RefundDecorator
    delegate :pos_order_id, to: :payment
  end
end

Spree::Refund.prepend Spree::Retail::RefundDecorator
