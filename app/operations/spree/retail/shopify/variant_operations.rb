module Spree
  module Retail
    module Shopify
      class VariantOperations
        class << self
          def create(spree_variant:)
            service = VariantUpdater.new(spree_variant: spree_variant)
            service.perform
          end

          def update(spree_variant:)
            service = VariantUpdater.new(spree_variant: spree_variant)
            service.perform
          end

          def destroy(spree_variant:)
            return false if spree_variant.pos_variant_id.nil?

            shopify_variant = ShopifyAPI::Variant.find_by_id(spree_variant.pos_variant_id)
            shopify_variant.present? ? shopify_variant.destroy : false
          end
        end
      end
    end
  end
end
