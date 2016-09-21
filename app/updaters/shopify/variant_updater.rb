module Shopify
  class VariantUpdater
    def initialize(spree_variant_id:, variant_klass: Spree::Variant,
                   variant_api: ShopifyAPI::Variant)

      @spree_variant = variant_klass.find(spree_variant_id)
      @variant_api = variant_api
    end

    def perform
      shopify_variant = find_shopify_variant_for(spree_variant)
      if shopify_variant.persisted?
        shopify_variant.update_attributes(variant_attributes)
      else
        shopify_variant.attributes = variant_attributes
        shopify_variant.save
      end
      save_pos_variant_id(spree_variant, shopify_variant)

      shopify_variant
    end

    private

    attr_accessor :spree_variant, :variant_api

    def find_shopify_variant_for(spree_variant)
      variant_api.find_or_initialize_by_id(spree_variant.pos_variant_id, params: { product_id: spree_variant.product.pos_product_id })
    end

    # FIXME: refactor this
    def save_pos_variant_id(variant, shopify_variant)
      variant.pos_variant_id = shopify_variant.id
      variant.save
    end

    def variant_attributes
      Shopify::VariantAttributes.new(spree_variant).attributes
    end
  end
end
