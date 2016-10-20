module Spree
  module Retail
    module Shopify
      class HooksController < ApplicationController
        skip_before_action :verify_authenticity_token
        skip_before_filter :restrict_access
        before_filter :verify_request_authenticity

        private

        def verify_request_authenticity
          data = request.body.read

          payload_validator = Spree::Retail::Shopify::ShopifyPayload.new(data, env)
          head :unauthorized unless payload_validator.valid?
        end
      end
    end
  end
end
