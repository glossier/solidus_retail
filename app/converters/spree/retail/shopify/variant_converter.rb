module Spree
  module Retail
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
            requires_shipping: false,
            updated_at: variant.updated_at
          }.merge(variant_uniqueness_constraint).merge(variant_product_id)
        end

        private

        attr_reader :variant, :aggregated

        # NOTE: We can't manually set the title of the variant, the first
        # option is always the title of the variant, which is really weird.
        def variant_uniqueness_constraint
          { option1: variant_title_value }
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

        def variant_title_value
          return variant.sku unless variant.option_values.any?

          variant.option_values.first.presentation
        end
      end
    end
  end
end
