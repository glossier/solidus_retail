module Spree
  module Retail
    class ImageToBase64Encoder
      def initialize(image, style: nil)
        @image = image
        @style = style
      end

      def encode
        return nil if image.nil? || image.attachment.nil?

        copy_image_locally!(image)
        encode_image(local_destination_path_for(image))
      end

      private

      attr_accessor :image, :style

      def encode_image(image_path)
        bytes = open(image_path, 'rb').read
        Base64.encode64(bytes)
      end

      def copy_image_locally!(image)
        local_destination_path = local_destination_path_for(image)
        image.attachment.copy_to_local_file(style, local_destination_path)
      end

      def local_destination_path_for(image)
        Rails.root.join('tmp', image.attachment.instance.attachment_file_name)
      end
    end
  end
end
