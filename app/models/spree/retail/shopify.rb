module Spree
  module Retail
    module Shopify
      class TransactionNotFoundError < StandardError; end
      class CreditedAmountBiggerThanTransaction < StandardError; end
    end
  end
end
