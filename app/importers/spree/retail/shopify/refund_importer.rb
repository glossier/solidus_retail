module Spree
  module Retail
    module Shopify
      class RefundImporter
        def initialize(shopify_refund, callback, logger: RefundLogger)
          @shopify_refund = shopify_refund
          @spree_order = find_spree_order_for(shopify_refund)
          @callback = callback
          @logger = logger.new(shopify_refund)
        end

        def perform
          unless refund_already_exists?(spree_order)
            Refund.create(spree_order, return_items)
          end

          callback.success_case
        rescue => e
          logger.exception_raised(e)
          callback.failure_case
        end

        private

        attr_accessor :shopify_refund, :spree_order, :callback, :logger

        def refund_already_exists?(spree_order)
          exists = spree_order.returned?
          logger.already_exists(spree_order) if exists

          exists
        end

        def return_items
          @_return_items ||= ReturnItems.new(spree_order, shopify_refund).all
        end

        def find_spree_order_for(shopify_refund)
          Spree::Order.find_by(pos_order_id: spree_order_id_for(shopify_refund))
        end

        def spree_order_id_for(shopify_refund)
          shopify_refund.prefix_options[:order_id]
        end
      end
    end
  end
end
