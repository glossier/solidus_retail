module Spree
  module Retail
    module Shopify
      class UserExporter
        def initialize(spree_user:, user_api: ShopifyAPI::User, attributor: UserAttributes)
          @spree_user = spree_user
          @user_api = user_api
          @attributor = attributor
        end

        def perform
          shopify_user = find_shopify_user_for(spree_user)

          shopify_user.update_attributes(user_attributes)
          save_associations_for(spree_user, shopify_user)

          shopify_user
        end

        private

        attr_accessor :spree_user, :user_api, :attributor

        def find_shopify_user_for(spree_user)
          user_api.find_or_initialize_by_id(spree_user.pos_user_id)
        end

        def save_associations_for(spree_user, shopify_user)
          AssociationSaver.save_pos_user_id(spree_user, shopify_user)
        end

        def user_attributes
          attributor.new(spree_user).attributes_with_variants
        end
      end
    end
  end
end
