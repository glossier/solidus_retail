require 'spec_helper'
require 'solidus_retail/order/generate_pos_order'

RSpec.describe SolidusRetail::Order::GeneratePosOrder, type: :model do
  include_context 'shopify_request'

  let!(:response_mock) { mock_request('orders/450789469', 'json') }
  let!(:store) { create :store }
  let!(:shipping_method) { create :shipping_method, admin_name: 'POS' }
  let!(:stock_location) { create :stock_location, admin_name: 'POPUP' }
  let(:payment_method) { create :payment_method, name: 'Shopify' }
  let(:variant) { create :variant }
  let(:order_response) { ShopifyAPI::Order.find('450789469') }

  before :each do
    allow(Spree::Variant).to receive(:find_by) { variant }
    allow(Spree::PaymentMethod).to receive(:where) { [payment_method] }
  end

  subject { described_class.new(order_response) }

  describe '#process' do
    subject { described_class.new(order_response).process }

    it 'successfully creates a solidus order' do
      expect{ subject }.to change(Spree::Order, :count).by 1
    end
  end
end
