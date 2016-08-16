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
      shopify_product.variants = build_variants(spree_product.variants)

      shopify_product
    end

    private

    attr_accessor :spree_product, :shopify_product

    def build_variants(spree_variants)
      return if spree_variants.empty?
      variants = []
      spree_variants.each do |variant|
        shopify_variant = find_or_initialize_variant(variant)
        factory = Shopify::VariantFactory.new(variant, shopify_variant)
        variants << factory.perform
      end

      variants
    end

    def surround_by_p_tags(content)
      [content.lines.map { |line| "<p>#{line.strip}</p>" }].join
    end

    def find_or_initialize_variant(spree_variant)
      shopify_variant = ::ShopifyAPI::Variant.find(spree_variant.pos_variant_id) if spree_variant.pos_variant_id
      shopify_variant = ::ShopifyAPI::Variant.new if shopify_variant.nil?

      shopify_variant
    end
  end
end
