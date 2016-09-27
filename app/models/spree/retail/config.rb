module Spree
  module Retail
    class Config < Spree::Base
      class << self
        attr_accessor :shopify_api_key
        attr_accessor :shopify_password
        attr_accessor :shopify_shop_name

        def shop_url
          "https://#{shopify_api_key}:#{shopify_password}@#{shopify_shop_name}"
        end
      end
    end
  end
end
