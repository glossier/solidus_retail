module Spree
  module ShopifyHook
    class OrdersController < ShopifyHookController
      def create
        head :ok
      end
    end
  end
end
