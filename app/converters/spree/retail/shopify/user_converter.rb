module Spree
  module Retail
    module Shopify
      class UserConverter
        def initialize(user:, address_converter: AddressConverter)
          @user = user
          @converter = address_converter
        end

        def to_hash
          {
            email: user.email,
            first_name: user_first_name,
            last_name: user_last_name,
            verified_email: true
          }.merge(ship_address_attrs).merge(bill_address_attrs)
        end

        private

        attr_reader :user, :converter

        def ship_address
          user.ship_address
        end

        def bill_address
          user.bill_address
        end

        def bill_address_attrs
          return {} unless bill_address.present?
          converter.new(bill_address, user).to_hash
        end

        def ship_address_attrs
          return {} unless ship_address.present?
          converter.new(ship_address, user).to_hash
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
