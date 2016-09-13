module Shopify
  class PartAttributes
    include Spree::Retail::PresenterHelper

    def initialize(part:, permutation:, part_converter: Shopify::PartConverter)
      @part = part
      @converter = part_converter
      @permutation = permutation
    end

    def attributes
      converter.new(part: presented_part, permutation: permutation).to_hash
    end

    attr_reader :part, :permutation, :converter

    def presented_part
      presented = present(part, :part)
      presented.permutation = permutation
      presented
    end
  end
end
