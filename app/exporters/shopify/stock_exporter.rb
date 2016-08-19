module Shopify
  class StockExporter
    def initialize(spree_variant_id, logger = nil)
      @logger = logger || default_logger
      @spree_variant = Spree::Variant.find(spree_variant_id)
      @shopify_variant = ShopifyAPI::Variant.find(spree_variant.pos_variant_id)
    end

    def perform
      old_inventory_quantity = shopify_variant.inventory_quantity
      shopify_variant.inventory_quantity = spree_variant.count_on_hand
      logger.info("#{spree_variant.sku} inventory quantity updated from #{old_inventory_quantity} to #{spree_variant.count_on_hand}")
      shopify_variant.save

      shopify_variant
    end

    attr_accessor :spree_variant, :shopify_variant, :logger

    private

    def default_logger
      Logger.new(Rails.root.join('log/export_solidus_stocks.log'))
    end
  end
end
