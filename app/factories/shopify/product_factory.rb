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
      shopify_product.variants = build_variants(spree_product)

      shopify_product
    end

    private

    attr_accessor :spree_product, :shopify_product

    def build_variants(spree_product)
      variants = [build_variant(spree_product.master)]

      spree_product.variants.each do |variant|
        variants << build_variant(variant)
      end

      variants
    end

    def build_variant(variant)
      shopify_variant = find_or_initialize_variant(variant)
      Shopify::VariantFactory.new(variant, shopify_variant).perform
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
