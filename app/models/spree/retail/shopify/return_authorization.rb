module Spree
  module Retail
    module Shopify
      module ReturnAuthorization
        extend self

        def create(order, return_items)
          Spree::ReturnAuthorization.create(
            order: order,
            stock_location: stock_location_to_refund,
            return_reason_id: return_reason.id,
            memo: note,
            return_items: return_items
          )
        end

        private

        def return_reason
          Spree::ReturnReason.first
        end

        def stock_location_to_refund
          Spree::StockLocation.first
        end

        def note
          "Automated refund made by Shopify"
        end
      end
    end
  end
end
