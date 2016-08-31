module Spree
  module Retail
    class Shopify
      class TransactionNotFoundError < Error; end
      class CreditedAmountBiggerThanTransaction < Error; end
    end
  end
end
