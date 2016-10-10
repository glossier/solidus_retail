module Spree
  module Retail
    module Shopify
      class UserAttributes
        include PresenterHelper

        def initialize(spree_user, converter: UserConverter)
          @spree_user = spree_user
          @converter = converter
        end

        def attributes
          converter.new(user: spree_user).to_hash
        end

        private

        attr_reader :spree_user, :converter
      end
    end
  end
end
