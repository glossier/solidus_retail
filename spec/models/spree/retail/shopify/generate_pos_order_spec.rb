require 'spec_helper'

Spree.describe Spree::Retail::Shopify::GeneratePosOrder, type: :model do
  include_context 'shopify_request'

  let!(:store) { create :store }
  let!(:shipping_method) { create :shipping_method, admin_name: 'POS' }
  let!(:stock_location) { create :stock_location, admin_name: 'POPUP' }
  let!(:payment_method) { create :retail_payment_method }
  let!(:source) { create :credit_card, name: 'POS' }
  let(:variant) { create :variant }

  let!(:order_response_mock) { mock_request('orders', 'orders/450789469', 'json') }
  let!(:transaction_response_mock) { mock_request('transactions', 'orders/450789469/transactions', 'json') }
  let(:order_response) { ShopifyAPI::Order.find('450789469') }

  before :each do
    allow(Spree::Variant).to receive(:find_by) { variant }
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

    it 'creates the related taxes as order adjustments' do
      subject
      expect(last_order.line_items.first.adjustments.count).to eql(1)
    end

    it 'ships the shipments' do
      subject
      expect(last_order.shipments.state).to eql('shipped')
    end

    describe 'with bundled products' do
      let!(:li_part1) { create :variant, sku: 'GBB100-SET' }
      let!(:li_part2) { create :variant, sku: 'GML100-SET' }
      let!(:li_part3) { create :variant, sku: 'GSC100-SET' }
      let(:part_variant) { create :variant }

      before :each do
        allow_any_instance_of(ShopifyAPI::LineItem).to receive(:sku) { "PHASE2/GBB100-SET/GML100-SET/GSC100-SET" }
        variant.update_attribute(:sku, 'PHASE2')
        variant.product.parts << part_variant
        subject
      end

      it 'processes as an assembled or bundled product depending on the sku' do
        expect(bundled_product_order?).to be_truthy
      end

      it 'adds the specific line item parts that the user chose during checkout' do
        expect(line_item_parts.map(&:variant)).to eq [li_part1, li_part2, li_part3]
      end
    end
  end

  def bundled_product_order?
    last_order.line_items.first.product.assembly?
  end

  def line_item_parts
    last_order.line_items.first.part_line_items
  end

  def last_order
    Spree::Order.last
  end
end
