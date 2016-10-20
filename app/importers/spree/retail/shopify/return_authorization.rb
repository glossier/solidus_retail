module Spree
  module Retail
    module Shopify
      class ReturnAuthorization
        class << self
          def create(spree_order, return_items)
            Spree::ReturnAuthorization.create(
              spree_order: spree_order,
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

          def note
            "Automated refund made by Shopify"
          end
        end
      end
    end
  end
end
