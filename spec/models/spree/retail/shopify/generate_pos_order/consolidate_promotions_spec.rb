require 'spec_helper'

Spree.describe Spree::Retail::Shopify::GeneratePosOrder, type: :model do
  include_context 'create_default_shop'
  include_context 'shopify_request'

  describe '#apply_adjustments' do
    let(:discounted_shopify_order) { create_shopify_order('450789471') }
    let!(:shopify_order) { create_shopify_order('450789469') }
    let(:spree_order){ Spree::Order.new(state: 'address') }
    let(:variant) { create :variant }

    before :each do
      allow(Spree::Variant).to receive(:find_by) { variant }
      variant.stock_items.first.update_attribute(:count_on_hand, 1900)
      allow_any_instance_of(Spree::Order).to receive(:ensure_available_shipping_rates) { true }
      spree_order.save!
      spree_order.line_items.create!(variant: variant, quantity: 1)
    end

    context 'a shopify order with one discount code' do
      it 'creates an adjustment on the spree order' do
        apply_adjustment(spree_order, discounted_shopify_order)
        expect(spree_order.adjustments.count).to eq(1)
      end

      it 'creates an adjustment with the same amount and label as the shopify discount' do
        apply_adjustment(spree_order, discounted_shopify_order)
        expect(spree_order.adjustments.first.amount).to eq(discounted_shopify_order.discount_codes.first.amount.to_f)
        expect(spree_order.adjustments.first.label).to eq(discounted_shopify_order.discount_codes.first.code)
      end
    end

    it 'does not create an adjustment for an order with no shopify discount' do
      apply_adjustment(spree_order, shopify_order)
      expect(spree_order.adjustments).to be_empty
    end
  end

  def apply_adjustment(spree_order, shopify_order)
    Spree::Retail::Shopify::GeneratePosOrder.new(shopify_order).apply_adjustment(spree_order, shopify_order)
  end
end
