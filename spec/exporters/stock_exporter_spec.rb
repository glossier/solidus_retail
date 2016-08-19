require 'spec_helper'

describe Shopify::StockExporter do
  let(:spree_variant) { create(:variant) }
  let(:shopify_variant) { ShopifyAPI::Variant.new }
  let(:logger_instance) { double('logger') }

  before do
    allow(Spree::Variant).to receive(:find).and_return(spree_variant)
    allow(ShopifyAPI::Variant).to receive(:find).and_return(shopify_variant)
    allow_any_instance_of(ShopifyAPI::Variant).to receive(:save).and_return(true)
    allow(logger_instance).to receive(:info).and_return(true)

    shopify_variant.inventory_quantity = 0
  end

  context '.initialize' do
    subject { described_class.new(spree_variant.id) }

    it 'successfully does it\'s things' do
      expect(subject).to be_truthy
    end
  end

  context '.perform' do
    subject { described_class.new(spree_variant.id, logger_instance) }
    let(:count_on_hand) { 10 }

    before do
      allow(spree_variant).to receive(:count_on_hand).and_return(count_on_hand)
    end

    it 'saves the shopify variant' do
      expect(shopify_variant).to receive(:save).once
      subject.perform
    end

    it 'returns the shopify variant' do
      result = subject.perform
      expected_result = ShopifyAPI::Variant

      expect(result).to be_a(expected_result)
    end

    it 'assigns the count from solidus to shopify variant' do
      variant = subject.perform

      result = variant.inventory_quantity
      expected_result = count_on_hand

      expect(result).to be(expected_result)
    end

    describe 'logging' do
      it 'logs an info' do
        expect(logger_instance).to receive(:info).once
        subject.perform
      end
    end
  end
end
