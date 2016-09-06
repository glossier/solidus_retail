module Shopify
  class ProductConverter
    def initialize(product:)
      @product = product
    end

    def to_hash
      { title: product.name,
        body_html: product.description,
        created_at: product.created_at,
        updated_at: product.updated_at,
        published_at: product.available_on,
        vendor: product.vendor,
        handle: product.slug }
    end

    private

    attr_reader :product
  end
end
