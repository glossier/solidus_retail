module Shopify
  class ProductExporter
    def initialize(spree_product:,
                   product_api: ShopifyAPI::Product,
                   product_attributes: Shopify::ProductAttributes)

      @spree_product = spree_product
      @product_api = product_api
      @product_attributes = product_attributes
    end

    def save_product_on_shopify
      save_product_with_variants
      save_product_images
    end

    private

    attr_accessor :spree_product, :product_api,
                  :product_attributes

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
      product_api.find_or_initialize_by(id: spree_product.pos_product_id)
    end

    def save_associations_for(spree_product, shopify_product)
      AssociationSaver.save_pos_product_id(spree_product, shopify_product)
      AssociationSaver.save_pos_variant_id_for_variants(spree_product.variants_including_master, shopify_product.variants)
    end

    def product_attributes_with_variants
      Shopify::ProductAttributes.new(spree_product).attributes_with_variants
    end

    def product_attributes_with_images
      Shopify::ProductAttributes.new(spree_product).attributes_with_images
    end

    class AssociationSaver
      class << self
        def save_pos_variant_id_for_variants(spree_variants, shopify_variants)
          shopify_variants.each do |shopify_variant|
            spree_variant = spree_variants.find_by(sku: shopify_variant.sku)
            next if spree_variant.nil?

            save_pos_variant_id(spree_variant, shopify_variant)
          end
        end

        def save_pos_variant_id(spree_variant, shopify_variant)
          spree_variant.pos_variant_id = shopify_variant.id
          spree_variant.save

          spree_variant.reload
          spree_variant
        end

        def save_pos_product_id(spree_product, shopify_product)
          spree_product.pos_product_id = shopify_product.id
          spree_product.save

          spree_product.reload
          spree_product
        end
      end
    end
  end
end
