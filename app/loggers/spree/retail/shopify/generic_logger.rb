module Spree
  module Retail
    module Shopify
      class GenericLogger
        def log(content)
          logger.info("LOG - #{format_string(content)}")
        end

        def skip(reason = nil)
          logger.info("SKIP - #{format_string(reason)}")
        end

        def error(reason = nil)
          logger.error("ERROR - #{format_string(reason)}")
        end

        private

        def format_string(content = nil)
          "#{object_representation} #{content}"
        end

        def object_representation
          ''
        end

        def logger
          Logger.new(Rails.root.join('log/retail_generic.log'))
        end
      end
    end
  end
end
