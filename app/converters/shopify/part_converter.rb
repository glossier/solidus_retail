module Shopify
  class PartConverter
    def initialize(part:, permutations:)
      @part = part
      @permutations = permutations
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

    def option_values
      container = []
      permutations.each_with_index do |permutation, index|
        container << { "option#{index + 1}" => permutation[:option_value_text] }
      end

      container.reduce({}, :merge)
    end

    attr_reader :part, :permutations
  end
end
