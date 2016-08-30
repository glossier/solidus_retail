module Spree
  class ShopifyHookController < ApplicationController
    before_filter :verify_webhook

    private

    def verify_webhook
      hmac_header = env['HTTP_X_SHOPIFY_HMAC_SHA256']
      data = request.body.read

      digest = OpenSSL::Digest::Digest.new('sha256')
      calculated_hmac = Base64.encode64(OpenSSL::HMAC.digest(digest, shared_secret, data)).strip
      authorized = calculated_hmac == hmac_header

      head :unauthorized unless authorized
    end

    def shared_secret
      ENV.fetch('SHOPIFY_SHARED_SECRET')
    end

    def json_body
      @_json_body ||= JSON.parse(request.body.read)
    end
  end
end
