require 'spec_helper'

Spree.describe Spree::Retail::Shopify::GeneratePosOrder, type: :model do
  include_context 'create_default_shop'
  include_context 'shopify_request'

  let(:shopify_order) { create_shopify_order('450789469') }
  let(:shopify_cash_order) { create_shopify_order('450789470') }
  let(:variant) { create :variant }

  before :each do
    allow(Spree::Variant).to receive(:find_by) { variant }
    variant.stock_items.first.update_attribute(:count_on_hand, 1900)
    allow_any_instance_of(Spree::Order).to receive(:ensure_available_shipping_rates) { true }
  end

  subject { described_class.new(shopify_order) }

  describe '#process' do
    subject { described_class.new(shopify_order).process }

    it 'successfully creates a solidus order' do
      expect{ subject }.to change(Spree::Order, :count).by 1
    end

    it 'creates an order that is in the complete state' do
      subject
      expect(last_order).to be_complete
    end

    it 'creates an order that was paid for with cash' do
      subject { described_class.new(shopify_cash_order).process }
      expect(last_order).to be_complete
    end

    it 'creates the related taxes as order adjustments' do
      subject
      expect(last_order.line_items.first.adjustments.count).to eql(1)
    end

    it 'ships the shipments' do
      subject
      expect(last_order.shipments).to all(be_shipped)
    end

    describe 'with bundled products' do
      let!(:li_part1) { create :variant, sku: 'GBB100-SET' }
      let!(:li_part2) { create :variant, sku: 'GML100-SET' }
      let!(:li_part3) { create :variant, sku: 'GSC100-SET' }
      let!(:single_sku_1) { create :variant, sku: 'GBB100' }
      let!(:single_sku_2) { create :variant, sku: 'GML100' }
      let!(:single_sku_3) { create :variant, sku: 'GSC100' }
      let(:part_variant) { create :variant }

      before :each do
        allow_any_instance_of(ShopifyAPI::LineItem).to receive(:sku) { "PHASE2/GBB100-SET/GML100-SET/GSC100-SET" }
        variant.update_attribute(:sku, 'PHASE2')
        variant.product.parts << [li_part1, li_part2, li_part3]
        ensure_stock
        subject
      end

      it 'processes as an assembled or bundled product depending on the sku' do
        expect(bundled_product_order?).to be_truthy
      end

      it 'adds the specific line item parts that the user chose during checkout' do
        expect(line_item_parts.map(&:variant)).to eq [single_sku_1, single_sku_2, single_sku_3]
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

  def ensure_stock
    Spree::StockItem.update_all(count_on_hand: 10)
  end
end
