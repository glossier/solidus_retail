RSpec.shared_context 'shopify_shop' do
  let(:refund_amount) { 100 }
  let(:shopify_payment_method) do
    gateway = ::Spree::Gateway::ShopifyGateway.new
    gateway.set_preference(:api_key, ENV.fetch('SHOPIFY_API_KEY'))
    gateway.set_preference(:password, ENV.fetch('SHOPIFY_PASSWORD'))
    gateway.set_preference(:shop_name, ENV.fetch('SHOPIFY_SHOP_NAME'))
    gateway
  end

  def create_fulfilled_paid_shopify_order
    # Refactor this
    # Should only be called once (use VCR)
    order = ::ShopifyAPI::Order.new
    order.email = 'cab@godynamo.com'
    order.test = true
    order.fulfillment_status = 'fulfilled'
    order.line_items = [
      {
        variant_id: '447654529',
        quantity: 1,
        name: 'test',
        price: refund_amount,
        title: 'title'
      }
    ]
    order.customer = { first_name: 'Paul',
                       last_name: 'Norman',
                       email: 'paul.norman@example.com' }

    order.billing_address = {
      first_name: 'John',
      last_name: 'Smith',
      address1: '123 Fake Street',
      phone: '555-555-5555',
      city: 'Fakecity',
      province: 'Ontario',
      country: 'Canada',
      zip: 'K2P 1L4'
    }
    order.shipping_address = {
      first_name: 'John',
      last_name: 'Smith',
      address1: '123 Fake Street',
      phone: '555-555-5555',
      city: 'Fakecity',
      province: 'Ontario',
      country: 'Canada',
      zip: 'K2P 1L4'
    }
    order.transactions = [
      {
        kind: 'capture',
        status: 'success',
        amount: refund_amount
      }
    ]
    order.financial_status = 'paid'
    order.save

    order
  end
end
