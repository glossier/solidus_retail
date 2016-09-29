module Spree
  module Retail
    module Shopify
      class PartConverter
        def initialize(part:, permutation:)
          @part = part
          @permutation = permutation
        end

        def to_hash
          {
            weight: part.weight,
            weight_unit: part.weight_unit,
            price: part.price,
            sku: part.sku,
            updated_at: part.updated_at
          }.merge(option_values)
        end

        private

        attr_reader :part, :permutation

        def option_values
          container = []
          permutation.each_with_index do |permutation, index|
            container << { :"option#{index + 1}" => permutation[:option_value_text] }
          end

          container.reduce({}, :merge)
        end
      end
    end
  end
end
