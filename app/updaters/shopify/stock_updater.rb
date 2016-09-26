module Shopify
  class StockUpdater
    def initialize(spree_variant:,
                   variant_api: ShopifyAPI::Variant,
                   stock_klass: Spree::StockLocation)

      @spree_variant = spree_variant
      @variant_api = variant_api
      @stock_klass = stock_klass
    end

    def perform
      shopify_variant = find_shopify_variant_for(spree_variant)

      previous_variant_count_on_hand = shopify_variant.inventory_quantity
      shopify_variant.inventory_quantity = current_variant_count_on_hand
      shopify_variant.old_inventory_quantity = previous_variant_count_on_hand
      shopify_variant.save

      shopify_variant
    end

    private

    attr_accessor :spree_variant, :variant_api, :stock_klass

    def find_shopify_variant_for(spree_variant)
      variant_api.find_or_initialize_by_id(spree_variant.pos_variant_id, params: { product_id: spree_variant.product.pos_product_id })
    end

    def current_variant_count_on_hand
      @_count ||= spree_variant.count_on_hand_for(stock_location)
    end

    def stock_location
      stock_klass.first
    end
  end
end
