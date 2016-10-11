module Spree
  module Retail
    module Shopify
      class ShopifyPayload
        def initialize(payload, env)
          @payload = payload
          @env = env
        end

        def valid?
          digest = OpenSSL::Digest::Digest.new('sha256')
          calculated_hmac = Base64.encode64(OpenSSL::HMAC.digest(digest, shared_secret, payload)).strip
          calculated_hmac == hmac_header
        end

        private

        attr_reader :payload, :env

        def shared_secret
          Spree::Retail::Config.shopify_webhook_shared_secret
        end

        def hmac_header
          env['HTTP_X_SHOPIFY_HMAC_SHA256']
        end
      end
    end
  end
end
