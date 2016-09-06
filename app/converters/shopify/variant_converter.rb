module Shopify
  class VariantConverter
    def initialize(spree_variant)
      @spree_variant = spree_variant
    end

    def to_hash
      {
        weight: spree_variant.weight,
        weight_unit: spree_variant.weight_unit,
        price: spree_variant.price,
        sku: spree_variant.sku,
        updated_at: spree_variant.updated_at
      }.merge(options).merge(variant_uniqueness_constraint)
    end

    private

    attr_reader :spree_variant

    def options
      options = {}
      spree_variant.option_values.each_with_index do |option, index|
        options[:"option#{index + 2}"] = option.name
      end

      options
    end

    def variant_uniqueness_constraint
      { option1: spree_variant.sku }
    end
  end
end
