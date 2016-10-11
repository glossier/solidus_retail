module Spree
  module Retail
    module Shopify
      module Hooks
        class RefundsController < HooksController
          def create
            shopify_refund = ShopifyAPI::Refund.find(shopify_refund_id, params: { order_id: shopify_order_id })
            Spree::Retail::Shopify::GenerateRefundOrder.new(shopify_refund).process

            head :ok
          end

          def shopify_refund_id
            params[:id]
          end

          def shopify_order_id
            params[:order_id]
          end
        end
      end
    end
  end
end
