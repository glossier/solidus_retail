module Spree
  module Retail
    module Shopify
      class HooksController < ApplicationController
        before_filter :verify_request_authenticity

        private

        def verify_request_authenticity
          data = request.body.read

          head :unauthorized unless request_authentified?(data, Spree::Retail::Config.shopify_shared_secret)
        end

        def request_authentified?(data, secret)
          hmac_header = env['HTTP_X_SHOPIFY_HMAC_SHA256']
          digest = OpenSSL::Digest::Digest.new('sha256')
          calculated_hmac = Base64.encode64(OpenSSL::HMAC.digest(digest, secret, data)).strip
          calculated_hmac == hmac_header
        end

        def json_body
          @_json_body ||= JSON.parse(request.body.read)
        end
      end
    end
  end
end
