module Shopify
  class ProductImagesFactory
    def initialize(spree_variant)
      @spree_variant = spree_variant
    end

    def perform
      shopify_image = ShopifyAPI::Image.new
      shopify_image.src = placeholder_image_url
      shopify_image.variant_ids = [spree_variant.pos_variant_id]
      # created_at
      # updated_at

      shopify_image
    end

    private

    def placeholder_image_url
      'http://placekitten.com.s3.amazonaws.com/homepage-samples/200/286.jpg'
    end

    attr_accessor :spree_variant
  end
end
