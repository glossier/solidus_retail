module Spree
  module Retail
    module Shopify
      module Hooks
        class OrdersController < HooksController
          def create
            shopify_order = ShopifyAPI::Order.find(shopify_order_id)
            Spree::Retail::Shopify::GeneratePosOrder.new(shopify_order).process

            head :ok
          end

          def shopify_order_id
            json_body['id']
          end
        end
      end
    end
  end
end
