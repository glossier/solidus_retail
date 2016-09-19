module Shopify
  class VariantConverter
    def initialize(variant:, aggregated: false)
      @variant = variant
      @aggregated = aggregated
    end

    def to_hash
      {
        weight: variant.weight,
        weight_unit: variant.weight_unit,
        price: variant.price,
        sku: variant.sku,
        inventory_management: 'shopify',
        updated_at: variant.updated_at
      }.merge(variant_uniqueness_constraint).merge(variant_product_id)
    end

    private

    attr_reader :variant, :aggregated

    def variant_uniqueness_constraint
      { option1: variant.sku }
    end

    def variant_product_id
      return {} unless add_product_id?

      { product_id: variant_product.pos_product_id }
    end

    def add_product_id?
      aggregated == false
    end

    def variant_product
      variant.product
    end
  end
end
