require 'shopify_api'

module ActiveMerchant #:nodoc:
  module Billing #:nodoc:
    class ShopifyGateway < Gateway
      self.homepage_url = 'https://shopify.ca/'
      self.display_name = 'Shopify'

      def initialize(options = {})
        requires!(options, :api_key)
        requires!(options, :password)
        requires!(options, :shop_name)

        @api_key = options[:api_key]
        @password = options[:password]
        @shop_name = options[:shop_name]

        @refunder_class = options[:refunder] || default_refunder
        @transaction_repository = options[:transaction_repository] || default_transaction_repository

        init_shopify_api!

        super
      end

      def void(transaction_id, options = {})
        transaction = transaction_repository.find(transaction_id,
                                                  params: options.slice(:order_id))

        return_response refunder_class.new(credited_money: transaction.amount,
                                           transaction: transaction).perform
      end

      def refund(money, transaction_id, options = {})
        transaction = transaction_repository.find(transaction_id,
                                                  params: options.slice(:order_id))

        return_response refunder_class.new(credited_money: money,
                                           transaction: transaction).perform
      end

      private

      attr_reader :api_key, :password, :shop_name, :refunder_class, :transaction_repository

      def init_shopify_api!
        ShopifyAPI::Base.site = shop_url
      end

      def shop_url
        "https://#{api_key}:#{password}@#{shop_name}"
      end

      def default_refunder
        Spree::Retail::Shopify::Refunder
      end

      def default_transaction_repository
        ShopifyAPI::Transaction
      end

      def return_response(result)
        success = result.errors == []
        if success || result.errors.messages.empty?
          ActiveMerchant::Billing::Response.new(true, nil)
        else
          ActiveMerchant::Billing::Response.new(success, result.errors.messages)
        end
      end
    end
  end
end
