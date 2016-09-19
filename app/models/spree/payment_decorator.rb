module Spree::Retail
  module PaymentDecorator
    delegate :pos_order_id, to: :order
  end
end

Spree::Payment.prepend Spree::Retail::PaymentDecorator
