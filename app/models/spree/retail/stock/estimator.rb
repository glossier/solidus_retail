module Spree::Retail
  module Stock
    class Estimator < Spree::Stock::Estimator
      def shipping_rates(package, frontend_only = false)
        super
      end
    end
  end
end
