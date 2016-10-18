module Spree
  module Retail
    module Shopify
      class CustomerImporter
        def initialize(customer: shopify_customer, converter: CustomerConverter)
          @shopify_customer = customer
          @converter = converter
        end

        def perform
          attributes = customer_attributes_for(shopify_customer)
          if customer_already_exists?(shopify_customer)
            raise "Please define me"
          else
            create_spree_user_with(attributes)
          end
        end

        private

        attr_reader :shopify_customer, :converter

        def customer_attributes_for(shopify_customer)
          converter.new(shopify_customer).to_hash
        end

        def customer_already_exists?(shopify_customer)
          find_spree_user_by(shopify_customer)
        end

        def find_spree_user_by(shopify_customer)
          user_scope.find_by(pos_customer_id: shopify_customer.id) ||
            user_scope.find_by(email: shopify_customer.email)
        end

        def create_spree_user_with(customer_attributes)
          user_scope.create(customer_attributes)
        end

        def user_scope
          Spree.user_class
        end
      end
    end
  end
end
