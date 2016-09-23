require 'spec_helper'
require 'solidus_retail/order/generate_pos_order'

RSpec.describe SolidusRetail::Order::GeneratePosOrder, type: :model do
  include_context 'shopify_request'

  let!(:store) { create :store }
  let!(:shipping_method) { create :shipping_method, admin_name: 'POS' }
  let!(:stock_location) { create :stock_location, admin_name: 'POPUP' }
  let!(:payment_method) { create :retail_payment_method }
  let!(:source) { create :credit_card, name: 'POS' }
  let(:variant) { create :variant }

  let!(:response_mock) { mock_request('orders/450789469', 'json') }
  let(:order_response) { ShopifyAPI::Order.find('450789469') }

  before :each do
    allow(Spree::Variant).to receive(:find_by) { variant }
    allow(Spree::PaymentMethod).to receive_message_chain(:where, :find_by) { payment_method }
    allow_any_instance_of(Spree::Order).to receive(:ensure_available_shipping_rates) { true }
    variant.stock_items.first.update_attribute(:count_on_hand, 1900)
  end

  subject { described_class.new(order_response) }

  describe '#process' do
    subject { described_class.new(order_response).process }

    it 'successfully creates a solidus order' do
      expect{ subject }.to change(Spree::Order, :count).by 1
    end

    it 'creates an order that is in the complete state' do
      subject
      expect(last_order).to be_complete
    end
  end

  def last_order
    Spree::Order.last
  end
end
