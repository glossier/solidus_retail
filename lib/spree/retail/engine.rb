require 'solidus_core'
require 'deface'
require 'shopify_api'

module Spree
  module Retail
    class Engine < Rails::Engine
      isolate_namespace Spree
      engine_name 'solidus_retail'

      initializer "spree.gateway.payment_methods", after: "spree.register.payment_methods" do |app|
        app.config.spree.payment_methods << Spree::Gateway::ShopifyGateway
      end

      # use rspec for tests
      config.generators do |g|
        g.test_framework :rspec
      end

      def self.activate
        Dir.glob(root.join('{app,lib}/**/*_decorator*.rb')) do |c|
          Rails.configuration.cache_classes ? require(c) : load(c)
        end
      end

      config.to_prepare(&method(:activate).to_proc)
    end
  end
end
