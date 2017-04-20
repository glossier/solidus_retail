module Spree
  module Retail
    module Shopify
      class AddressConverter
        def initialize(address:)
          @address = address
        end

        def to_hash
          {
            address1: address.address1,
            address2: address.address2,
            city: address.city,
            first_name: address.firstname,
            last_name: address.lastname,
            phone: address.phone,
            zip: address.zipcode,
            province: address.state.name,
            country_code: address.country.iso3,
            updated_at: address.updated_at
          }
        end

        private

        attr_reader :address
      end
    end
  end
end
