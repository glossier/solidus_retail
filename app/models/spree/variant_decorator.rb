module Spree
  module VariantDecorator
    attr_accessor :disable_shopify_sync

    def self.prepended(base)
      base.after_create :create_shopify_variant, if: :should_export_to_shopify?
      base.after_update :update_shopify_variant, if: :should_export_to_shopify?
      base.after_destroy :destroy_shopify_variant, if: :should_export_to_shopify?
    end

    def count_on_hand_for(stock_location)
      stock_items.find_by(stock_location_id: stock_location.id).count_on_hand
    end

    private

    def create_shopify_variant
      require 'pry'; binding.pry
      service = Shopify::VariantUpdater.new(spree_variant_id: id)
      service.perform
    end

    def update_shopify_variant
      service = Shopify::VariantUpdater.new(spree_variant_id: id)
      service.perform
    end

    def destroy_shopify_variant
      return false if pos_variant_id.nil?

      shopify_variant = ShopifyAPI::Variant.find_by_id(pos_variant_id)
      shopify_variant.present? ? shopify_variant.destroy : false
    end

    def should_export_to_shopify?
      disable_shopify_sync != true
    end
  end
end

Spree::Variant.prepend Spree::VariantDecorator
