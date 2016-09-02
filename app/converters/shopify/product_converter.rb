module Shopify
  class ProductConverter
    def initialize(spree_product:, shopify_product:)
      @spree_product = spree_product
      @shopify_product = shopify_product
    end

    def perform
      shopify_product.title = spree_product.name
      shopify_product.body_html = spree_product.description
      shopify_product.created_at = spree_product.created_at
      shopify_product.updated_at = spree_product.updated_at
      shopify_product.published_at = spree_product.available_on
      shopify_product.vendor = spree_product.vendor
      shopify_product.handle = spree_product.slug

      shopify_product
    end

    private

    attr_accessor :spree_product, :shopify_product
  end
end
