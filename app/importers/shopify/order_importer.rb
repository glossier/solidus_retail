module Shopify
  class OrderImporter
    GENERIC_EMAIL = 'not-provided@glossier.com'
    POS_CHANNEL = 'shopify'

    def initialize(pos_order_id)
      @logger = logger || default_logger
      @pos_order = ::ShopifyAPI::Order.find(pos_order_id)
      @order = spree_order_scope.where(pos_order_id: pos_order_id).first_or_create!
    end

    def spree_order_scope
      # ::Spree::Order.by_channel('shopify')
      ::Spree::Order.where(channel: POS_CHANNEL)
    end

    def perform
      begin
        return if pos_order_already_imported?

        order.email = customer_email
        order.created_at = pos_order.created_at
        order.number = pos_order_number
        order.pos_order_id = pos_order.id
        order.channel = POS_CHANNEL
        # NOTE(cab): This will send an email to the customer to confirm when
        # the order has been delivered if set to false. Since we do not support
        # delivery, we should not allow Solidus to send that type of emails.
        order.confirmation_delivered = true

        add_line_items(order, pos_order)

        transition_order_from_cart_to_address!(order)
        transition_order_from_address_to_delivery!(order)
        transition_order_from_delivery_to_payment!(order)
        transition_order_from_payment_to_confirm!(order)
        transition_order_from_confirm_to_complete!(order)

        set_completed_at(order, pos_order.created_at)

        # Assign user afterwards
        # (so a credit card payment does not get created automatically if user
        # has a CC profile in the database - see Spree::Order::Checkout)
        if user = Spree::User.find_by(email: order.email)
          order.user = user
          order.save
        else
          logger.error "Customer: #{pos_customer.try(:email)} is not found in Solidus for the order #{pos_order.try(:name)}"
        end

        order
      rescue => e
        logger.error "#{pos_order.try(:name)}: #{e}"
      end
    end

    private

    attr_reader :pos_order, :order, :logger

    def add_line_items(order, pos_order)
      return unless order.cart?

      stock_location = Spree::StockLocation.find_by!(admin_name: 'POPUP')

      pos_order.line_items.each do |item|
        logger.info "Adding #{item.sku} line-item to #{pos_order_number}."

        if variant = Spree::Variant.find_by(sku: item.sku)
          order.line_items.where(variant: variant).first_or_create! do |li|
            stock_location.restock(variant, item.quantity)

            li.quantity = item.quantity
            li.price = item.price
          end
        else
          logger.error "Variant item: #{item.try(:sku)} is not found in Solidus for the order #{pos_order.try(:name)}"
        end
      end

      order.save!
    end

    # transitions
    #
    def transition_order_from_cart_to_address!(order)
      return unless order.cart?

      order.bill_address = customer_bill_address
      order.ship_address = glossier_address

      order.next!
    end

    def transition_order_from_address_to_delivery!(order)
      return unless order.address?

      order.next!
    end

    def transition_order_from_delivery_to_payment!(order)
      return unless order.delivery?

      order.next!
    end

    def transition_order_from_payment_to_confirm!(order)
      return unless order.payment?

      payment_method = Spree::PaymentMethod.find_by!(name: 'Shopify')

      # TODO(cab): We will need to enter more details about the payment here,
      # like the transaction_id of the Shopify Payment
      order.payments.create!(payment_method: payment_method, amount: order.total)
    end

    def transition_order_from_confirm_to_complete!(order)
      return if order.complete?

      order.next!
      # NOTE(cab): Why use capture here? The Shopify Gateway doesn't support that
      # order.payments.each(&:capture!)
      mark_as_shipped(order)
    end

    def mark_as_shipped(order)
      order.update_column('shipment_state', 'shipped')
      order.shipments.last.update_column('state', 'shipped')
    end

    def pos_order_already_imported?
      order.present? && order.complete?
    end

    def pos_order_number
      # Remove the # sign in the pos pos_order name
      pos_order.name.gsub(/[^\w-]/, '')
    end

    def customer_email
      if has_customer? && pos_customer.email.present?
        pos_customer.email
      else
        GENERIC_EMAIL
      end
    end

    def customer_last_name
      if has_customer? && pos_customer.last_name.present?
        pos_customer.last_name
      else
        'not provided'
      end
    end

    def customer_first_name
      if has_customer? && pos_customer.first_name.present?
        pos_customer.first_name
      else
        'not provided'
      end
    end

    def customer_bill_address
      if has_customer? && pos_customer.default_address.present?
        address = pos_customer.default_address
        create_solidus_address_from_shopify(address)
      else
        glossier_address
      end
    end

    def set_completed_at(order, date)
      order.update_attribute(:completed_at, date)
    end

    def glossier_address
      usa = Spree::Country.find_by!(iso: 'US')
      ny = usa.states.find_by!(abbr: 'NY')

      Spree::Address.create(address1: '123 Lafayette St.',
                            firstname: customer_first_name,
                            lastname: customer_last_name,
                            city: 'New York',
                            state: ny,
                            country: usa,
                            zipcode: '10013',
                            phone: '555-555-5555')
    end

    def create_solidus_address_from_shopify(address)
      country = Spree::Country.find_by!(iso: address.country_code)
      state = country.states.find_by!(abbr: address.province_code)

      Spree::Address.create(address1: address.address1,
                            address2: address.address2,
                            firstname: address.first_name,
                            lastname: address.last_name,
                            city: address.city,
                            state: state,
                            country: country,
                            zipcode: address.zip,
                            phone: address.phone)
    end

    def pos_customer
      pos_order.customer
    end

    def has_customer?
      pos_order.respond_to? :customer
    end

    def default_logger
      Logger.new(Rails.root.join('log/import_shopify_orders.log'))
    end
  end
end
