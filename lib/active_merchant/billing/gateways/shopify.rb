require 'shopify_api'

module ActiveMerchant #:nodoc:
  module Billing #:nodoc:
    class ShopifyGateway < Gateway
      class TransactionNotFoundError < Error; end
      class CreditedAmountBiggerThanTransaction < Error; end

      self.homepage_url = 'https://shopify.ca/'
      self.display_name = 'Shopify'

      def initialize(options = {})
        requires!(options, :api_key)
        requires!(options, :password)
        requires!(options, :shop_name)

        @api_key = options[:api_key]
        @password = options[:password]
        @shop_name = options[:shop_name]

        init_shopify_api!

        super
      end

      def void(transaction_id, options = {})
        order_id = options[:order_id]
        voider = ShopifyVoider.new(transaction_id, order_id)
        voider.perform
      end

      def refund(money, transaction_id, options = {})
        refunder = ShopifyRefunder.new(money, transaction_id, options)
        refunder.perform
      end

      private

      attr_reader :api_key, :password, :shop_name

      def init_shopify_api!
        ::ShopifyAPI::Base.site = shop_url
      end

      def shop_url
        "https://#{api_key}:#{password}@#{shop_name}"
      end
    end
  end
end
