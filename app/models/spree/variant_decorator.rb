module Spree
  module VariantDecorator
    # Generic method that can get overwritten by Solidus Application in order to
    # define what is the image we want to have uploaded on the POS system.
    def default_pos_image
      return '' if images.empty?

      images.first
    end
  end
end

Spree::Variant.prepend Spree::VariantDecorator
