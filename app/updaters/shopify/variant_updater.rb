module Shopify
  class VariantUpdater
    def initialize(spree_variant_id:, variant_klass: Spree::Variant, variant_api: ShopifyAPI::Variant, attributor: Shopify::VariantAttributes)
      @spree_variant = variant_klass.find(spree_variant_id)
      @variant_api = variant_api
      @attributor = attributor
    end

    def perform
      shopify_variant = find_shopify_variant_for(spree_variant)
      shopify_variant.update_attributes(variant_attributes)
      Shopify::AssociationSaver.save_pos_variant_id(spree_variant, shopify_variant)

      shopify_variant
    end

    private

    attr_accessor :spree_variant, :variant_api, :attributor

    def find_shopify_variant_for(spree_variant)
      variant_api.find_or_initialize_by(id: spree_variant.pos_variant_id)
    end

    def variant_attributes
      attributor.new(spree_variant).attributes
    end
  end
end
