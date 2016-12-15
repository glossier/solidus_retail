module Spree
  module Retail
    module Shopify
      module Hooks
        class RefundsController < HooksController
          def create
            shopify_refund = ShopifyAPI::Refund.find(shopify_refund_id, params: { order_id: shopify_order_id })
            Spree::Retail::Shopify::RefundImporter.new(shopify_refund, callback: self).perform

            head :ok
          end

          def success_case
            head :ok
          end

          def failure_case
            head :internal_server_error
          end

          private

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
