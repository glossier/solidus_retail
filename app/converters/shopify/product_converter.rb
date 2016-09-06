module Shopify
  class ProductConverter
    def initialize(spree_product)
      @spree_product = spree_product
    end

    def to_hash
      { title: spree_product.name,
        body_html: spree_product.description,
        created_at: spree_product.created_at,
        updated_at: spree_product.updated_at,
        published_at: spree_product.available_on,
        vendor: spree_product.vendor,
        handle: spree_product.slug }
    end

    private

    attr_reader :spree_product
  end
end
