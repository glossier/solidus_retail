module Shopify
  class VariantConverter
    def initialize(variant:)
      @variant = variant
    end

    def to_hash
      {
        product_id: variant.product_id,
        weight: variant.weight,
        weight_unit: variant.weight_unit,
        price: variant.price,
        sku: variant.sku,
        updated_at: variant.updated_at
      }.merge(options).merge(variant_uniqueness_constraint)
    end

    private

    attr_reader :variant

    def options
      options = {}
      variant.option_values.each_with_index do |option, index|
        options[:"option#{index + 2}"] = option.name
      end

      options
    end

    def variant_uniqueness_constraint
      { option1: variant.sku }
    end
  end
end
