module Spree
  module Retail
    module Shopify
      class CustomerImporter
        def initialize(shopify_customer)
          @shopify_customer = shopify_customer
        end

        def perform
        end

        private

        attr_reader :shopify_customer
      end
    end
  end
end
