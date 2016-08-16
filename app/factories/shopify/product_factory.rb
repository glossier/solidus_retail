module Shopify
  class ProductFactory
    def initialize(spree_product, shopify_product)
      @spree_product = spree_product
      @shopify_product = shopify_product
    end

    def perform
      shopify_product.title = spree_product.name
      shopify_product.body_html = surround_by_p_tags(spree_product.description)
      shopify_product.created_at = spree_product.created_at
      shopify_product.updated_at = spree_product.updated_at
      shopify_product.published_at = spree_product.available_on
      shopify_product.vendor = 'Glossier'
      shopify_product.handle = spree_product.slug

      if spree_product.variants.any?
        factory = Shopify::VariantFactory.new

        spree_product.variants.each do |_variant|
          factory.perform
        end
      end

      shopify_product
    end

    private

    attr_accessor :spree_product, :shopify_product

    def surround_by_p_tags(content)
      [content.lines.map { |line| "<p>#{line.strip}</p>" }].join
    end
  end
end
