module Spree
  module PaymentDecorator
    delegate :pos_order_id, to: :order
  end
end

Spree::Payment.prepend Spree::PaymentDecorator
