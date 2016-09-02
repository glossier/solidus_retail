module Shopify
  class VariantConverter
    def initialize(spree_variant:, shopify_variant:, weight_unit: nil)
      @spree_variant = spree_variant
      @shopify_variant = shopify_variant
      @weight_unit = weight_unit || default_weight_unit
    end

    def perform
      shopify_variant.weight = spree_variant.weight
      shopify_variant.weight_unit = weight_unit
      shopify_variant.price = spree_variant.price
      shopify_variant.sku = spree_variant.sku
      shopify_variant.updated_at = spree_variant.updated_at
      generate_options!

      shopify_variant
    end

    private

    attr_accessor :spree_variant, :shopify_variant, :weight_unit

    def generate_options!
      assign_variant_uniqueness_constraint(spree_variant.sku)

      spree_variant.option_values.each_with_index do |option, index|
        shopify_variant.send("option#{index + 2}=", option.name)
      end
    end

    def assign_variant_uniqueness_constraint(value)
      shopify_variant.option1 = value
    end

    # NOTE: The weight_unit can be either 'g', 'kg, 'oz', or 'lb'.
    def default_weight_unit
      'oz'
    end
  end
end
