module Spree
  module RefundDecorator
    def pos_order_id
      # NOTE(cab): Should we use delegates here?
      payment.order.pos_order_id
    end
  end
end

Spree::Refund.prepend Spree::RefundDecorator
