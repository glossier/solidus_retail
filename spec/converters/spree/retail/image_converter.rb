module Spree
  module Retail
    class ImageToBase64Converter
      def initialize(image, style: nil)
        @image = image
        @style = style || default_style
      end

      def perform
        return nil unless image.attachment.exists?

        copy_image_locally!(image)
        encode_image(local_destination_path_for(image))
      end

      private

      attr_accessor :image, :style

      def encode_image(image_path)
        bytes = open(image_path, "rb").read
        Base64.encode64(bytes)
      end

      def copy_image_locally!(image)
        local_destination_path = local_destination_path_for(image.attachment)
        image.attachment.copy_to_local_file(style, local_destination_path)
      end

      def local_destination_path_for(attachment)
        Rails.root.join('tmp', attachment.instance.attachment_file_name)
      end

      def default_style
        nil
      end
    end
  end
end
