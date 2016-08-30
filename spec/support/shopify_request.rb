class ShopifyRequest
  class << self
    def create_order
      read_file('create_order.txt')
    end

    def retrieve_complete_order
      read_file('retrieve_complete_order.txt')
    end

    private

    def read_file(filename)
      file_path = File.join(support_folder, request_folder, filename)
      file = File.open(file_path)

      file.read
    end

    def support_folder
      File.join(SolidusRetail::Engine.root, 'spec', 'support')
    end

    def request_folder
      'shopify_requests'
    end
  end
end
