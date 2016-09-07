require 'solidus_core'
require 'shopify_api'

module Spree
  module Retail
    class Engine < Rails::Engine
      isolate_namespace Spree
      engine_name 'solidus_retail'

      # TODO(cab): To remove and instead priorize a configuration initializer
      require 'dotenv-rails'
      Dotenv.load

      # use rspec for tests
      config.generators do |g|
        g.test_framework :rspec
      end

      def self.activate
        Dir.glob(root.join('app/**/*_decorator*.rb')) do |c|
          Rails.configuration.cache_classes ? require(c) : load(c)
        end
      end

      config.to_prepare(&method(:activate).to_proc)
    end
  end
end
