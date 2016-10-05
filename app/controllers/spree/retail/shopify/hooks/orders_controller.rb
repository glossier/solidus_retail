module Spree
  module Retail
    module Shopify
      module Hooks
        class OrdersController < HooksController
          def create
            head :ok
          end
        end
      end
    end
  end
end
