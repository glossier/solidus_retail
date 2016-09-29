module Spree
  module Retail
    module Shopify
      class ProductUpdater
        def initialize(spree_product:,
                       product_api: ShopifyAPI::Product,
                       attributor: ProductAttributes,
                       exporter: ProductExporter)

          @spree_product = spree_product
          @product_api = product_api
          @exporter = exporter
          @attributor = attributor
        end

        def perform
          shopify_product = find_shopify_product_for(spree_product)

          return export_product unless shopify_product.persisted?

          update_shopify_product(shopify_product)
        end

        private

        attr_accessor :spree_product, :product_api, :exporter, :attributor

        def find_shopify_product_for(spree_product)
          product_api.find_or_initialize_by_id(spree_product.pos_product_id)
        end

        def update_shopify_product(shopify_product)
          shopify_product.update_attributes(product_attributes)
          AssociationSaver.save_pos_product_id(spree_product, shopify_product)

          shopify_product
        end

        def export_product
          exporter.new(spree_product: spree_product).perform
        end

        def product_attributes
          attributor.new(spree_product).attributes
        end
      end
    end
  end
end
