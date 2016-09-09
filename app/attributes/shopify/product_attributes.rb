module Shopify
  class ProductAttributes
    include Spree::Retail::PresenterHelper

    def initialize(spree_product, product_converter: Shopify::ProductConverter,
                   variant_attributes: Shopify::VariantAttributes)

      @spree_product = spree_product
      @converter = product_converter
      @variant_attributes = variant_attributes
    end

    def attributes
      converter.new(product: presented_product).to_hash
    end

    def attributes_with_variants
      attributes.merge!(attributes_for_variants)
    end

    private

    attr_reader :spree_product, :converter, :variant_attributes

    def presented_product
      present(spree_product, :product)
    end

    def attributes_for_variants
      attributes = { variants: [] }

      variant_scope.each do |variant|
        attributes[:variants] << variant_attributes.new(variant).attributes
      end

      attributes
    end

    def variant_scope
      spree_product.variants_including_master
    end
  end
end
