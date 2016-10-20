module Spree
  module Retail
    module Shopify
      module CustomerReturn
        class << self
          def create(return_items)
            Spree::CustomerReturn.create(
              stock_location: stock_location_to_refund,
              return_items: return_items
            )
          end

          private

          def stock_location_to_refund
            Spree::StockLocation.first
          end
        end
      end
    end
  end
end
