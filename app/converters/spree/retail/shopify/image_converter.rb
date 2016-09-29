module Spree
  module Retail
    module Shopify
      class ImageConverter
        def initialize(image:, pos_variant_id:, image_encoder: Spree::Retail::ImageToBase64Encoder)
          @image = image
          @pos_variant_id = pos_variant_id
          @image_encoder = image_encoder
        end

        def to_hash
          { variant_ids: [pos_variant_id],
            attachment: convert_to_base64(image) }
        end

        private

        attr_reader :image, :pos_variant_id, :image_encoder

        def convert_to_base64(image)
          image_encoder.new(image).encode
        end
      end
    end
  end
end
