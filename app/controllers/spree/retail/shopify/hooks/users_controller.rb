module Spree
  module Retail
    module Shopify
      module Hooks
        class UsersController < HooksController
          def create
            shopify_customer = ShopifyAPI::Customer.find(shopify_customer_id)
            Spree::Retail::Shopify::CustomerImporter.new(shopify_customer).perform

            head :ok
          end

          def shopify_customer_id
            params[:id]
          end
        end
      end
    end
  end
end
