module Shopify
  class GiftCardAttributes
    include Spree::Retail::PresenterHelper

    def initialize(spree_gift_card, converter: Shopify::GiftCardConverter)
      @spree_gift_card = spree_gift_card
      @converter = converter
    end

    def attributes
      converter.new(gift_card: spree_gift_card).to_hash
    end

    private

    attr_reader :spree_gift_card, :converter
  end
end
