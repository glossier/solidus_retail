module Spree
  module Retail
    module Shopify
      class CustomerConverter
        def initialize(shopify_customer)
          @shopify_customer = shopify_customer
        end

        def to_hash
          {
            email: shopify_customer.email,
            password: development_default_password,
            updated_at: shopify_customer.updated_at
          }
        end

        private

        attr_reader :shopify_customer

        def development_default_password
          'i-like-turtles-2016'
        end
      end
    end
  end
end
