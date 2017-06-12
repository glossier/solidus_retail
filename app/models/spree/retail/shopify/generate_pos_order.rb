module Spree
  module Retail
    module Shopify
      class GeneratePosOrder
        GENERIC_EMAIL = 'retailguest@glossier.com'

        def initialize(order)
          @order = order
        end

        def process
          if deployed_environment? && Spree::Order.where('pos_order_number = ?', @order.name.to_s).count > 0
            puts "skipping #{@order.order_number} - already imported"
            return
          end
          order = create_order
          order.pos_order_number = @order.name
          order.pos_order_id = @order.id
          order.channel = 'pos'
          order.email = customer_email
          order.created_at = @order.created_at
          order.save!
          add_line_items(order, @order)

          transition_order_from_cart_to_address!(order)
          transition_order_from_address_to_delivery!(order)
          transition_order_from_delivery_to_payment!(order)
          transition_order_from_payment_to_confirm!(order, @order)
          transition_order_from_confirm_to_complete!(order)

          # Assign user afterwards
          # (so a credit card payment does not get created automatically if user
          # has a CC profile in the database - see Spree::Order::Checkout)
          if user = Spree.user_class.find_by_email(order.email)
            order.user = user
            order.save
          end

          order
        end

        def create_order
          Spree::Order.new(currency: ::Spree::Config[:currency], pos: true)
        end

        def add_line_items(order, pos_order)
          pos_order.line_items.each do |item|
            if item.sku =~ /\w\/\w/
              add_bundled_item(order, item)
            else
              line_item = Spree::LineItem.new(quantity: item.quantity)
              # This is because we're seeing some line items returned from Shopify with a nil sku
              sku = item.sku.blank? ? ShopifyAPI::Variant.find(item.variant_id).sku : item.sku
              line_item.variant = Spree::Variant.find_by(sku: sku)
              line_item.price = item.price
              line_item.currency = pos_order.currency

              order.line_items << line_item
              line_item.order = order
              line_item.adjustments = build_adjustments(item, line_item, order)
              line_item.save
            end
          end
          order.save!
        end

        def build_adjustments(shopify_line_item, spree_line_item, order)
          adjustments = []
          shopify_line_item.tax_lines.each do |tax|
            adjustment = spree_line_item.adjustments.tax.build
            adjustment.amount = tax.price
            adjustment.label = tax.title
            adjustment.order = order
            adjustment.finalized = true
            adjustments << adjustment
          end

          adjustments
        end

        def add_bundled_item(order, item)
          line_item = Spree::LineItem.new(quantity: item.quantity).tap do |li|
            li.variant = Spree::Variant.find_by(sku: item.sku.split('/')[0])
            li.price = item.price
          end
          order.line_items << line_item
          add_line_item_parts(item, line_item, order)
          line_item.order = order
        end

        def add_line_item_parts(item, line_item, order)
          Spree::Variant.where(sku: variant_skus_for_bundle(item), hidden: false).each do |part_variant|
            line_item.part_line_items.create(variant: part_variant, quantity: 1, line_item: line_item)
            line_item.adjustments = build_adjustments(item, line_item, order)
            line_item.save
          end
        end

        # transitions
        #
        def transition_order_from_cart_to_address!(order)
          order.bill_address = order.ship_address = Spree::Address.create(address1: '123 Lafayette St.',
                                                                          firstname: customer_first_name,
                                                                          lastname: customer_last_name,
                                                                          city: 'New York',
                                                                          state_id: 48,
                                                                          country_id: 49,
                                                                          zipcode: '10013',
                                                                          phone: '555-555-5555')

          order.next!
        end

        def transition_order_from_address_to_delivery!(order)
          apply_adjustment(order)
          order.next!
        end

        def transition_order_from_delivery_to_payment!(order)
          order.shipments.first.stock_location = Spree::StockLocation.find_by(admin_name: 'POPUP')
          if order.shipments.first.shipping_method.nil?
            order.shipments.first.add_shipping_method(Spree::ShippingMethod.find_by(admin_name: '00FESP'), true)
          end
          order.next!
        end

        def transition_order_from_payment_to_confirm!(spree_order, shopify_order)
          payment = spree_order.payments.create(payment_method: default_payment_method)
          payment.amount = spree_order.total
          captured_payment = shopify_order.transactions.find { |t| t.kind == 'capture' }
          payment.response_code = captured_payment.nil? ? shopify_order.transactions.first.id : captured_payment.id
          payment.save
        end

        def transition_order_from_confirm_to_complete!(order)
          return if order.complete?
          order.next!
          order.payments.each(&:capture!)
          Spree::OrderUpdater.new(order).update
          order.complete!
          mark_as_shipped(order)
        end

        def apply_adjustment(spree_order)
          shopify_discount = @order.discount_codes.first
          return unless shopify_discount
          spree_order.adjustments.create!(amount: shopify_discount.amount, label: shopify_discount.code, order: spree_order, adjustment_reason: adjustment_reason)
        end

        def mark_as_shipped(order)
          order.contents.approve(name: 'Shopify Auto Approver')
          order.shipments.each do |shipment|
            shipment.suppress_mailer = true
            shipment.ship!
          end
        end

        def customer_email
          if has_customer? && @order.customer.email.present?
            @order.customer.email
          else
            GENERIC_EMAIL
          end
        end

        def customer_last_name
          if has_customer? && @order.customer.last_name.present?
            @order.customer.last_name
          else
            'not provided'
          end
        end

        def customer_first_name
          if has_customer? && @order.customer.first_name.present?
            @order.customer.first_name
          else
            'not provided'
          end
        end

        def has_customer?
          @order.respond_to? :customer
        end

        def deployed_environment?
          !Rails.env.development? && !Rails.env.test?
        end

        private

        def default_payment_method
          Spree::PaymentMethod.find_by(name: 'Shopify')
        end

        def variant_skus_for_bundle(item)
          [].tap do |variants|
            item.sku.split('/').drop(1).each do |v|
              variants << v
            end
          end
        end

        def adjustment_reason
          Spree::AdjustmentReason.find_or_create_by(name: 'Shopify Discount', code: 'shopify_discount')
        end
      end
    end
  end
end
