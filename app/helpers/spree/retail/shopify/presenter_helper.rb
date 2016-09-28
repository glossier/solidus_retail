module Spree
  module Retail
    module Shopify
      module PresenterHelper
        def present(object, presenter_type)
          presenter_klass = "#{presenter_type}_presenter".camelcase
          klass = "Spree::Retail::Shopify::#{presenter_klass}".constantize
          presenter = klass.new(object)
          yield presenter if block_given?
          presenter
        end
      end
    end
  end
end
