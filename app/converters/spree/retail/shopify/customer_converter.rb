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
            first_name: shopify_customer.first_name,
            last_name: shopify_customer.last_name,
            password: development_default_password
            # verified_email: shopify_customer.verified_email,
            # updated_at: shopify_customer.updated_at
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
