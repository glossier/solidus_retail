module Spree
  module Retail
    module Shopify
      class UserConverter
        def initialize(user:, address_converter: AddressConverter)
          @user = user
          @address_converter = address_converter
        end

        def to_hash
          {
            email: user.email,
            first_name: user_first_name,
            last_name: user_last_name,
            verified_email: true
          }.merge(default_address)
        end

        private

        attr_reader :user, :address_converter

        def ship_address
          user.ship_address
        end

        def ship_address_attrs
          return {} unless ship_address.present?
          address_converter.new(address: ship_address).to_hash
        end

        def default_address
          { default_address: ship_address_attrs }
        end

        def user_last_name
          ship_address.present? ? ship_address.lastname : 'UNDEFINED'
        end

        def user_first_name
          ship_address.present? ? ship_address.firstname : 'UNDEFINED'
        end
      end
    end
  end
end
