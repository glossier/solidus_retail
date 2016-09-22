module Shopify
  class ProductAttributes
    include Spree::Retail::PresenterHelper

    def initialize(spree_product, converter: Shopify::ProductConverter, variant_attributor: Shopify::VariantAttributes)
      @spree_product = spree_product
      @converter = converter
      @variant_attributor = variant_attributor
    end

    def attributes
      converter.new(product: presented_product).to_hash
    end

    def attributes_with_variants
      attributes.merge!(attributes_for_variants)
    end

    private

    attr_reader :spree_product, :converter, :variant_attributor

    def presented_product
      present(spree_product, :product)
    end

    def attributes_for_variants
      attributes = { variants: [] }

      variant_scope.each do |variant|
        attributes[:variants] << variant_attributor.new(variant).attributes
      end

      attributes
    end

    def variant_scope
      spree_product.variants_including_master
    end
  end
end
