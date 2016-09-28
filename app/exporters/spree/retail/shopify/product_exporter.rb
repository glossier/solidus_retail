module Spree
  module Retail
    module Shopify
      class ProductExporter
        def initialize(spree_product:, product_api: ShopifyAPI::Product, attributor: ProductAttributes)
          @spree_product = spree_product
          @product_api = product_api
          @attributor = attributor
        end

        def perform
          save_product_with_variants
          save_product_images
        end

        private

        attr_accessor :spree_product, :product_api, :attributor

        def save_product_with_variants
          shopify_product = find_shopify_product_for(spree_product)

          shopify_product.update_attributes(product_attributes_with_variants)
          save_associations_for(spree_product, shopify_product)

          shopify_product
        end

        def save_product_images
          shopify_product = find_shopify_product_for(spree_product)
          # NOTE: There are no ways to pin-point an image, so let's flush them all
          # and re-upload them
          shopify_product.images = nil
          shopify_product.update_attributes(product_attributes_with_images)

          shopify_product
        end

        def find_shopify_product_for(spree_product)
          product_api.find_or_initialize_by_id(spree_product.pos_product_id)
        end

        def save_associations_for(spree_product, shopify_product)
          AssociationSaver.save_pos_product_id(spree_product, shopify_product)
          AssociationSaver.save_pos_variant_id_for_variants(spree_product.variants_including_master, shopify_product.variants)
        end

        def product_attributes_with_variants
          attributor.new(spree_product).attributes_with_variants
        end

        def product_attributes_with_images
          attributor.new(spree_product).attributes_with_images
        end
      end
    end
  end
end
