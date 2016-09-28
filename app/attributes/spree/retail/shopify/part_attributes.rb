module Spree
  module Retail
    module Shopify
      class PartAttributes
        include PresenterHelper

        def initialize(part:, permutation:, part_converter: PartConverter)
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
  end
end
