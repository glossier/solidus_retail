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
      shopify_product = find_shopify_product_for(spree_product)

      shopify_product.update_attributes(product_attributes_with_variants)
      save_associations_for(spree_product, shopify_product)

      shopify_product
    end

    private

    attr_accessor :spree_product, :product_api,
                  :product_attributes

    def find_shopify_product_for(spree_product)
      product_api.find_or_initialize_by(id: spree_product.pos_product_id)
    end

    def save_associations_for(spree_product, shopify_product)
      Shopify::AssociationSaver.save_pos_product_id(spree_product, shopify_product)
      Shopify::AssociationSaver.save_pos_variant_id_for_variants(spree_product.variants_including_master, shopify_product.variants)
    end

    def product_attributes_with_variants
      Shopify::ProductAttributes.new(spree_product).attributes_with_variants
    end
  end
end
