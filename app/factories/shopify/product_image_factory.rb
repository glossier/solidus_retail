module Shopify
  class ProductImageFactory
    def initialize(spree_variant)
      @spree_variant = spree_variant
    end

    def perform
      shopify_image = ShopifyAPI::Image.new

      shopify_image.variant_ids = [spree_variant.pos_variant_id]
      shopify_image.attachment = encoded_image(variant_image)

      shopify_image
    end

    private

    def encoded_image(image)
      # When the image is hosted locally, we must get the `path` of the image,
      # else if it's hosted online we must get the `url` of the image.
      # I haven't found a better way of doing that yet.
      begin
        bytes = open(image.attachment.url, "rb").read
      rescue Errno::ENOENT
        bytes = open(image.attachment.path, "rb").read
      ensure
        encoded = Base64.encode64(bytes)
      end
      encoded
    end

    def variant_image
      spree_variant.default_pos_image
    end

    attr_accessor :spree_variant
  end
end
