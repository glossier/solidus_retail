module Shopify
  class GiftCardConverter
    def initialize(gift_card:)
      @gift_card = gift_card
    end

    def to_hash
      { initial_value: gift_card.amount,
        currency: gift_card.currency }
    end

    private

    attr_reader :gift_card
  end
end
