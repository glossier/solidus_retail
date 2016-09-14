require 'shopify_api'

module ActiveMerchant #:nodoc:
  module Billing #:nodoc:
    class ShopifyGateway < Gateway
      self.homepage_url = 'https://shopify.com/'
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
        transaction = find_transaction(transaction_id, options[:order_id])

        build_billing_response create_refund(transaction.amount, transaction)
      end

      def refund(money, transaction_id, options = {})
        transaction = find_transaction(transaction_id, options[:order_id])

        build_billing_response create_refund(money, transaction)
      end

      private

      attr_reader :api_key, :password, :shop_name, :refunder_class, :transaction_repository

      def create_refund(money, transaction)
        refunder_class.new(credited_money: money,
                           transaction: transaction).perform
      end

      def find_transaction(transaction_id, order_id)
        transaction_repository.find(transaction_id,
                                    params: { order_id: order_id })
      end

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

      def build_billing_response(result)
        success  = result.errors.empty?
        messages = success ? nil : result.errors.messages

        ActiveMerchant::Billing::Response.new(success, messages)
      end
    end
  end
end
