module Shopify
  class ProductImageConverter
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
      return nil unless image.attachment.exists?
      local_destination_path = local_destination_path_for(image.attachment)

      image.attachment.copy_to_local_file(default_style, local_destination_path)
      bytes = open(local_destination_path, "rb").read
      Base64.encode64(bytes)
    end

    def variant_image
      spree_variant.default_pos_image
    end

    def local_destination_path_for(attachment)
      Rails.root.join('tmp', attachment.instance.attachment_file_name)
    end

    def default_style
      nil
    end

    attr_accessor :spree_variant
  end
end
