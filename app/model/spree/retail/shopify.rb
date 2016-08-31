module Spree
  module Retail
    class Shopify
      class TransactionNotFoundError < StandardError; end
      class CreditedAmountBiggerThanTransaction < StandardError; end
    end
  end
end
