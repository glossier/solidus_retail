module Spree
  module Retail
    module Shopify
      class BundledProductExporter
        def initialize(spree_product:,
                       product_api: ShopifyAPI::Product,
                       bundle_attributes: BundledProductAttributes)

          @spree_product = spree_product
          @product_api = product_api
          @bundle_attributes = bundle_attributes
        end

        def perform
          shopify_product = find_shopify_product_for(spree_product)

          shopify_product.update_attributes(product_attributes_with_parts)
          save_associations_for(spree_product, shopify_product)

          shopify_product
        end

        private

        attr_accessor :spree_product, :product_api,
          :bundle_attributes

        def find_shopify_product_for(spree_product)
          product_api.find_or_initialize_by_id(spree_product.pos_product_id)
        end

        def save_associations_for(spree_product, shopify_product)
          AssociationSaver.save_pos_product_id(spree_product, shopify_product)
        end

        def product_attributes_with_parts
          bundle_attributes.new(spree_product).attributes
        end
      end
    end
  end
end
