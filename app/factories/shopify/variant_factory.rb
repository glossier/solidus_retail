module Shopify
  class VariantFactory
    def initialize(spree_variant, shopify_variant)
      @spree_variant = spree_variant
      @shopify_variant = shopify_variant
    end

    def perform
      shopify_variant.weight = spree_variant.weight
      shopify_variant.weight_unit = 'oz'
      shopify_variant.price = spree_variant.price
      shopify_variant.sku = spree_variant.sku
      shopify_variant.updated_at = spree_variant.updated_at
      shopify_variant.inventory_quantity = spree_variant.stock_items.count_on_hand
      generate_options!

      shopify_variant
    end

    private

    attr_accessor :spree_variant, :shopify_variant

    def generate_options!
      shopify_variant.option1 = spree_variant.sku

      spree_variant.option_values.each_with_index do |option, index|
        shopify_variant.send("option#{index + 2}=", option.name)
      end
    end
  end
end
