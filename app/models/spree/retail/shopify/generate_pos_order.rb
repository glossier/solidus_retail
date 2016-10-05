module Spree
  module Retail
    module Shopify
      class GeneratePosOrder
        GENERIC_EMAIL = ::Spree::Store.default.mail_from_address || ''

        def initialize(order)
          @order = order
        end

        def process
          if deployed_environment? && Spree::Order.complete.where('pos_order_number = ?', @order.name.to_s).count > 0
            puts "skipping #{@order.order_number} - already imported"
            return
          end
          order = create_order
          order.pos_order_number = @order.name
          order.email = customer_email
          order.channel = 'pos'
          order.created_at = @order.created_at
          order.save!
          add_line_items(order, @order)

          transition_order_from_cart_to_address!(order)
          transition_order_from_address_to_delivery!(order)
          transition_order_from_delivery_to_payment!(order)
          transition_order_from_payment_to_confirm!(order)
          transition_order_from_confirm_to_complete!(order)

          # Assign user afterwards
          # (so a credit card payment does not get created automatically if user
          # has a CC profile in the database - see Spree::Order::Checkout)
          if user = Spree.user_class.find_by_email(order.email)
            order.user = user
            order.save
          end

          order
        rescue => e
          puts "#{@order.try(:name)}: #{e}"
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
              line_item.variant = Spree::Variant.find_by(sku: item.sku)
              line_item.price = item.price
              line_item.currency = pos_order.currency

              order.line_items << line_item
              line_item.order = order
            end
          end
          order.save!
        end

        def add_bundled_item(order, item)
          line_item = Spree::LineItem.new(quantity: item.quantity).tap do |li|
            li.variant = Spree::Variant.find_by(sku: item.sku.split('/')[0])
            li.price = item.price
          end
          order.line_items << line_item
          add_line_item_parts(item, line_item)
          line_item.order = order
        end

        def add_line_item_parts(item, line_item)
          Spree::Variant.where(sku: item.sku.split('/')[1..3]).each do |part_variant|
            line_item.part_line_items.create(variant: part_variant, quantity: 1, line_item: line_item)
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
          shipment = order.shipments.create
          shipment.stock_location = Spree::StockLocation.find_by(admin_name: 'POPUP')
          shipment.save!
          order.shipments.last.add_shipping_method(Spree::ShippingMethod.find_by(admin_name: 'POS'), true)
          order.next!
        end

        def transition_order_from_delivery_to_payment!(order)
          order.next!
        end

        def transition_order_from_payment_to_confirm!(order)
          payment_method = Spree::PaymentMethod.find_by(name: 'Shopify')
          payment = order.payments.create(payment_method: payment_method)
          payment.amount = order.total
          payment.save
        end

        def transition_order_from_confirm_to_complete!(order)
          return if order.complete?
          order.next!
          order.payments.each(&:capture!)
          mark_as_shipped(order)
          Spree::OrderUpdater.new(order).update
          order.complete!
        end

        def mark_as_shipped(order)
          order.update_column('shipment_state', 'shipped')
          order.shipments.last.update_column('state', 'shipped')
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
      end
    end
  end
end
