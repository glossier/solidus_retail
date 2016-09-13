require 'shopify_api/resources/transaction'

module ShopifyAPI
  module TransactionDecorator
    def order_id
      @prefix_options[:order_id]
    end
  end
end

ShopifyAPI::Transaction.prepend ShopifyAPI::TransactionDecorator
