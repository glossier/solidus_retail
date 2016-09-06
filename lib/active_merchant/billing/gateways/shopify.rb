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

        @voider_class = options[:voider] || default_voider
        @refunder_class = options[:refunder] || default_refunder

        init_shopify_api!

        super
      end

      def void(transaction_id, options = {})
        order_id = options[:order_id]
        voider = voider_class.new(transaction_id, order_id)
        return_response(voider.perform)
      end

      def refund(money, transaction_id, options = {})
        refunder = refunder_class.new(credited_money: money, transaction_id: transaction_id, **options)
        return_response(refunder.perform)
      end

      private

      attr_reader :api_key, :password, :shop_name, :voider_class, :refunder_class

      def init_shopify_api!
        ShopifyAPI::Base.site = shop_url
      end

      def shop_url
        "https://#{api_key}:#{password}@#{shop_name}"
      end

      def default_voider
        Spree::Retail::ShopifyVoider
      end

      def default_refunder
        Spree::Retail::ShopifyRefunder
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
