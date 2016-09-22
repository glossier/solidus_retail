module Shopify
  class VariantAttributes
    include Spree::Retail::PresenterHelper

    def initialize(spree_variant, converter: Shopify::VariantConverter)
      @spree_variant = spree_variant
      @converter = converter
    end

    def attributes
      converter.new(variant: presented_variant, aggregated: true).to_hash
    end

    private

    attr_reader :spree_variant, :converter

    def presented_variant
      present(spree_variant, :variant)
    end
  end
end
