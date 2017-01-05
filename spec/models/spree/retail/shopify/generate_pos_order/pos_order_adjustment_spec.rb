require 'spec_helper'

Spree.describe Spree::Retail::Shopify::GeneratePosOrder, type: :model do
  include_context 'create_default_shop'
  include_context 'shopify_request'

  let(:spree_order) { create(:order, state: 'address', line_items: [line_item]) }
  let(:line_item) { create(:line_item, variant: variant) }
  let(:variant) do
    variant = create(:variant)
    variant.stock_items.first.update_attribute(:count_on_hand, 1900)
    variant
  end

  subject { Spree::Retail::Shopify::GeneratePosOrder.new(shopify_order) }

  before do
    subject.apply_adjustment(spree_order)
  end

  context 'a discounted order' do
    let(:shopify_order) { create_shopify_order('450789470') }

    it 'creates an adjustment on the spree order' do
      expect(spree_order.adjustments.count).to eq(1)
    end

    it 'creates an adjustment with the same amount and label as the shopify discount' do
      expect(spree_order.adjustments.first.amount).to eq(shopify_order.discount_codes.first.amount.to_f)
      expect(spree_order.adjustments.first.label).to eq(shopify_order.discount_codes.first.code)
    end

    it 'creates an adjustment with the adjustment type of "Shopify Discount"' do
      expect(spree_order.adjustments.first.adjustment_reason).to have_attributes(name: "Shopify Discount")
    end
  end

  context 'free order' do
    let(:shopify_order) { create_shopify_order('450789471') }

    it 'creates an adjustment for a free order' do
      expect(spree_order.adjustments.count).to eq(1)
      expect(spree_order.adjustments.first.amount).to eq(shopify_order.total_line_items_price.to_f)
    end
  end

  context 'no discount' do
    let(:shopify_order) { create_shopify_order('450789469') }

    it 'does not create an adjustment for an order with no shopify discount' do
      expect(spree_order.adjustments).to be_empty
    end
  end
end
