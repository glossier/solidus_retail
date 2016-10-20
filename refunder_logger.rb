module Spree
  module Retail
    module Shopify
      class RefunderLogger
        def initialize(shopify_refund)
          @shopify_refund = shopify_refund
        end

        def already_exists(spree_order)
          skip("The refund already exists for #{spree_order.number}")
        end

        def exception_raised(exception)
          error(exception)
        end

        private

        attr_accessor :shopify_refund

        def skip(reason = nil)
          logger.info("SKIP - #{format_string(reason)}")
        end

        def error(reason = nil)
          logger.error("ERROR - #{format_string(reason)}")
        end

        def format_string(reason = nil)
          "#{object_representation} #{reason}"
        end

        def object_representation
          "[Shopify Refund ID: #{shopify_refund.id}]"
        end

        def logger
          Logger.new(Rails.root.join('log/import_refund.log'))
        end
      end
    end
  end
end