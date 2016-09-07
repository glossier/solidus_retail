module Shopify
  class VariantExporter
    include Spree::Retail::PresenterHelper

    def initialize(spree_variant_id:, variant_klass: Spree::Variant,
                   variant_api: ShopifyAPI::Variant,
                   variant_converter: Shopify::VariantConverter)

      @spree_variant = variant_klass.find(spree_variant_id)
      @variant_converter = variant_converter
      @variant_api = variant_api
    end

    def perform
      shopify_variant = find_shopify_variant_for(spree_variant)
      shopify_variant.update_attributes(variant_attributes)
      save_pos_variant_id(spree_variant, shopify_variant)

      shopify_variant
    end

    private

    attr_accessor :spree_variant, :variant_api, :variant_converter

    def find_shopify_variant_for(spree_variant)
      variant_api.find_or_initialize_by(id: spree_variant.pos_variant_id)
    end

    def presented_variant
      present(spree_variant, :variant)
    end

    def save_pos_variant_id(variant, shopify_variant)
      variant.pos_variant_id = shopify_variant.id
      variant.save
    end

    def variant_attributes
      variant_converter.new(variant: presented_variant).to_hash
    end
  end
end
