class ShopifyRequest
  class << self
    def create_order
      file_path = File.join(support_folder, request_folder, 'create_order.txt')
      file = File.open(file_path)

      file.read
    end

    private

    def support_folder
      File.join(SolidusRetail::Engine.root, 'spec', 'support')
    end

    def request_folder
      'shopify_requests'
    end
  end
end
