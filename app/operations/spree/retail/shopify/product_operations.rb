module Spree
  module Retail
    module Shopify
      class ProductOperations
        class << self
          def create(spree_product:)
            service = ProductExporter.new(spree_product: spree_product)
            service.perform
          end

          def update(spree_product:)
            if spree_product.assembly?
              service = ::Spree::Retail::Shopify::BundledProductExporter.new(spree_product: spree_product)
            else
              service = ::Spree::Retail::Shopify::ProductUpdater.new(spree_product: spree_product)
            end

            service.perform
          end

          def destroy(spree_product:)
            return false if spree_product.pos_product_id.nil?

            shopify_product = ShopifyAPI::Product.find_by_id(spree_product.pos_product_id)
            shopify_product.present? ? shopify_product.destroy : false
          end
        end
      end
    end
  end
end
