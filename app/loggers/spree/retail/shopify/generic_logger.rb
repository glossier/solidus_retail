module Spree
  module Retail
    module Shopify
      module GenericLogger
        included do
          private

          def skip(reason = nil)
            logger.info("SKIP - #{format_string(reason)}")
          end

          def error(reason = nil)
            logger.error("ERROR - #{format_string(reason)}")
          end

          def format_string(content = nil)
            "#{object_representation} #{content}"
          end

          def logger
            fail(NotImplementedError,
                 "Need to define #{__method__} for #{self} class")
          end

          def object_representation
            fail(NotImplementedError,
                 "Need to define #{__method__} for #{self} class")
          end
        end
      end
    end
  end
end
