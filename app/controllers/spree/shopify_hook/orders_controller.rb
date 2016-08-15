module Spree
  module ShopifyHook
    class OrdersController < ShopifyHookController
      def create
        # PUT into the queue
        # When queue perform do the following:
        # Shopify::OrderImporter.new(pos_order_id).perform
        head :ok
      end

      private

      def pos_order_id
        json_body['id']
      end
    end
  end
end
