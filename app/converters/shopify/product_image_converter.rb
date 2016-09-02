module Shopify
  class ProductImageConverter
    def initialize(spree_variant:, image_api:)
      @spree_variant = spree_variant
      @image_api = image_api || default_image_api
    end

    def perform
      shopify_image = image_api.new
      shopify_image.variant_ids = [spree_variant.pos_variant_id]
      shopify_image.attachment = Spree::Retail::ImageToBase64Converter.new(variant_image)

      shopify_image
    end

    private

    attr_accessor :spree_variant, :image_api

    def variant_image
      spree_variant.default_pos_image
    end

    def default_image_api
      ShopifyAPI::Image
    end
  end
end
