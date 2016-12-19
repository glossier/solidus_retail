require 'spec_helper'

Spree.describe Spree::Retail::Shopify::GeneratePosOrder, type: :model do
  include_context 'create_default_shop'
  include_context 'shopify_request'

  describe 'shopify orders with a promotion' do
    let(:shopify_order) { create_shopify_order('450789471') }
    let(:variant) { create :variant }

    subject { described_class.new(shopify_order).process }

    before :each do
      allow(Spree::Variant).to receive(:find_by) { variant }
      variant.stock_items.first.update_attribute(:count_on_hand, 1900)
      allow_any_instance_of(Spree::Order).to receive(:ensure_available_shipping_rates) { true }
    end

    describe 'the promotion exists in solidus' do
      let!(:promotion) { Spree::Promotion.create!(name: 'Test Promotion') }

      # it 'successfully creates a solidus order with the found promotion' do
      #   promotion.update_columns(code: 'TWENTYOFF')
      #   spree_order = subject
      #   expect(spree_order.promotions.first.code).to_eq(promotion.code)
      # end

      # it 'successfully creates a solidus order with the correct adjustment' do
      #   spree_order = subject
      #   expect(spree_order.adjustments.first.amount).to_eq(shopify_order.total_discounts)
      # end
    end
  end

  describe '#apply_promotions' do
    describe 'shopify order with no discount codes' do
      let(:shopify_order) { create_shopify_order('450789469') }
      let(:spree_order){ Spree::Order.new(state: 'address') }
      let(:variant) { create :variant }
      let(:line_item) { Spree::LineItem.new(quantity: 1) }

      subject { described_class.new(shopify_order).apply_promotions(spree_order, shopify_order) }

      before :each do
        spree_order.line_items << line_item
        allow(Spree::Variant).to receive(:find_by) { variant }
        variant.stock_items.first.update_attribute(:count_on_hand, 1900)
        allow_any_instance_of(Spree::Order).to receive(:ensure_available_shipping_rates) { true }
      end

      it 'does nothing' do
        subject
        expect(spree_order.promotions).to be_empty
        expect(spree_order.adjustments).to be_empty
      end
    end

    describe 'shopify order with one discount code that exists in Spree' do
      let(:order) { create_shopify_order('450789471') }
      let(:spree_order){ Spree::Order.new(state: 'address') }
      let(:variant) { create :variant }
      let(:line_item) { Spree::LineItem.new(quantity: 1) }
      let!(:promotion) { Spree::Promotion.create!(name: 'Test Promotion') }

      subject { described_class.new(order).apply_promotions(spree_order, order) }

      before :each do
        spree_order.line_items << line_item
        allow(Spree::Variant).to receive(:find_by) { variant }
        variant.stock_items.first.update_attribute(:count_on_hand, 1900)
        allow_any_instance_of(Spree::Order).to receive(:ensure_available_shipping_rates) { true }
      end

      it 'determines if the shopify orders promotion code exists in Spree' do
        promotion.update_columns(code: 'TWENTYOFF')
        result = subject
        expect(result).to eq(true)
      end

      # it 'updates the Spree order to have the same total adjustment as the Shopify total discount' do
      #   promotion.update_columns(code: 'TWENTYOFF')
      #   subject
      #   expect(spree_order.adjustments.count).to eq(1)
      #   expect(spree_order.adjustments.first.code).to eq('TWENTYOFF')
      # end
    end
  end
end
