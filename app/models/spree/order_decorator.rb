module Spree
  module OrderDecorator
    def self.prepended(base)
      base.whitelisted_ransackable_attributes += %w[pos_order_number]
    end
  end
end

Spree::Order.prepend Spree::OrderDecorator
