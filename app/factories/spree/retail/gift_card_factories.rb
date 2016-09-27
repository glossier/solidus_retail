module Spree
  module Retail
    class GiftCardFactories
      def initialize(spree_gift_card:)
        @spree_gift_card = spree_gift_card

        ShopifyAPI::GiftCard.create(amount,currency,
redemption_code

      end

      private

      attr_reader :spree_gift_card  



    end
  end
end
