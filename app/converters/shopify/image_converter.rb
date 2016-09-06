module Shopify
  class ImageConverter
    def initialize(spree_variant:, image_serializer: nil)
      @spree_variant = spree_variant
      @image_serializer = image_serializer || default_image_serializer
    end

    def to_hash
      hash = { variant_ids: [spree_variant.pos_variant_id] }
      hash[:attachment] = convert_to_base64(variant_image) if image_present?

      hash
    end

    private

    attr_accessor :spree_variant, :image_serializer

    def variant_image
      spree_variant.default_pos_image
    end

    def convert_to_base64(image)
      image_serializer.new(image).serialize
    end

    def image_present?
      variant_image.present?
    end

    def default_image_serializer
      Spree::Retail::ImageToBase64Serializer
    end
  end
end
