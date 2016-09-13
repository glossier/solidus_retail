module SolidusRetail
  module Orders
    class GeneratePosOrder
      GENERIC_EMAIL = Spree::Store.mail_from_address || ''

      def initialize(order)
        @order = order
      end

      def process
        if !Rails.env.development? && Spree::Order.complete.where('pos_order_number = ?', @order.name.to_s).count > 0
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
        if user = Spree::User.find_by_email(order.email)
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
          if item.title == 'Phase 2 Set'
            add_phase_two_to_order(order, pos_order, item)
          else
            line_item = Spree::LineItem.new(quantity: item.quantity)
            line_item.variant = Spree::Variant.find_by(sku: item.sku)
            line_item.price = item.price

            order.line_items << line_item
            line_item.order = order
          end
        end
        order.save!
      end

      def add_phase_two_to_order(order, pos_order, item)
        # Parts need to be infered from item.variant_title where order =
        # Gen G / Boy Brow / Concealer
        # For ex: variant_title"=>"Cake / Brown / Medium"
        line_item = Spree::LineItem.new(quantity: item.quantity)
        line_item.variant = Spree::Variant.find_by(sku: 'PHASE2')
        line_item.price = item.price

        order.line_items << line_item
        line_item.order = order
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
        order.shipments.last.shipping_methods << Spree::ShippingMethod.find_by(admin_name: 'POS')
        order.next!
      end

      def transition_order_from_delivery_to_payment!(order)
        order.next!
      end

      def transition_order_from_payment_to_confirm!(order)
        payment_method = Spree::PaymentMethod.where(environment: Rails.env.to_s).find_by(name: 'Shopify')
        payment = order.payments.create(payment_method: payment_method)
        payment.amount = order.total
        payment.save
      end

      def transition_order_from_confirm_to_complete!(order)
        return if order.complete?
        order.next!
        order.payments.each(&:capture!)
        mark_as_shipped(order)
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
    end
  end
end
