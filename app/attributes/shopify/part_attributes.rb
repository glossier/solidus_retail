module Shopify
  class PartAttributes
    include Spree::Retail::PresenterHelper

    def initialize(part:, permutations:, part_converter: Shopify::PartConverter)
      @part = part
      @converter = part_converter
      @permutations = permutations
    end

    def attributes
      converter.new(part: presented_part, permutations: permutations).to_hash
    end

    attr_reader :part, :permutations, :converter

    def presented_part
      presented = present(part, :part)
      presented.permutations = permutations
      presented
    end
  end
end
