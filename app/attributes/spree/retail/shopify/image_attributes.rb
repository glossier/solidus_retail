module Spree
  module Retail
    module Shopify
      class ImageAttributes
        include Spree::Retail::PresenterHelper

        def initialize(spree_variant, image_converter: Shopify::ImageConverter)
          @spree_variant = spree_variant
          @converter = image_converter
        end

        def attributes
          converter.new(image: variant_image, pos_variant_id: spree_variant.pos_variant_id).to_hash
        end

        private

        attr_reader :spree_variant, :converter

        def presented_variant
          present(spree_variant, :variant)
        end

        def variant_image
          presented_variant.default_pos_image
        end
      end
    end
  end
end
