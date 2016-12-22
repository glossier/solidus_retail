require 'spec_helper'

Spree.describe Spree::Retail::Shopify::GeneratePosOrder, type: :model do
  include_context 'create_default_shop'
  include_context 'shopify_request'

  describe '#apply_adjustments' do

    describe 'a shopify order with one discount code' do
      let(:shopify_order) { create_shopify_order('450789471') }
      let(:spree_order){ Spree::Order.new(state: 'address') }
      let(:variant) { create :variant }

      subject { described_class.new(shopify_order).apply_adjustment(spree_order, shopify_order) }

      before :each do
        allow(Spree::Variant).to receive(:find_by) { variant }
        variant.stock_items.first.update_attribute(:count_on_hand, 1900)
        allow_any_instance_of(Spree::Order).to receive(:ensure_available_shipping_rates) { true }
        spree_order.save!
        spree_order.line_items.create!(variant: variant, quantity: 1)
      end
      
      it 'creates the adjustment on the spree order given the amount of the shopify discount amount' do
        subject
        expect(spree_order.adjustments[0].amount).to eq(shopify_order.discount_codes[0].amount.to_f)
        expect(spree_order.adjustments[0].label).to eq(shopify_order.discount_codes[0].code)
      end

      it 'updates the Spree order to have the same total adjustment as the Shopify total discount' do
        subject
        expect(spree_order.adjustments.count).to eq(1)
        expect(spree_order.adjustments.first.label).to eq('TWENTYOFF')
      end
    end

    describe 'a shopify order with no discount code' do
      let!(:shopify_order) { create_shopify_order('450789469') }
      let(:spree_order){ Spree::Order.new(state: 'address') }
      let(:variant) { create :variant }

      subject { described_class.new(shopify_order) }

      before :each do
        allow(Spree::Variant).to receive(:find_by) { variant }
        variant.stock_items.first.update_attribute(:count_on_hand, 1900)
        allow_any_instance_of(Spree::Order).to receive(:ensure_available_shipping_rates) { true }
        spree_order.save!
        spree_order.line_items.create!(variant: variant, quantity: 1)
      end

      it 'does not do anything' do
        subject.apply_adjustment(spree_order, shopify_order)
        expect(spree_order.adjustments).to be_empty
      end
    end
  end
end
