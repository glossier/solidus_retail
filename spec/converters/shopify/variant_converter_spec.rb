require 'spec_helper'

module Shopify
  RSpec.describe VariantConverter do
    let(:shopify_variant) { ShopifyAPI::Variant.new }
    let(:spree_variant) { create(:variant) }

    subject { described_class.new(spree_variant, shopify_variant) }

    before do
      allow_any_instance_of(Spree::Product).to receive(:export_to_shopify).and_return(true)
    end

    context '.initialize' do
      it 'successfully does it\'s things' do
        expect(subject).to be_truthy
      end
    end

    context '.perform' do
      it 'returns a variant shopify object' do
        result = subject.perform
        expected_result = ShopifyAPI::Variant

        expect(result).to be_an(expected_result)
      end

      context 'fills all the required fields' do
        before do
          @shopify_variant = subject.perform
        end

        it { expect(@shopify_variant.weight).to eql(spree_variant.weight) }
        it { expect(@shopify_variant.weight_unit).to eql('oz') }
        it { expect(@shopify_variant.price).to eql(spree_variant.price) }
        it { expect(@shopify_variant.sku).to eql(spree_variant.sku) }
        it { expect(@shopify_variant.updated_at).to eql(spree_variant.updated_at) }
        it { expect(@shopify_variant.option1).to eql(spree_variant.sku) }
      end

      context 'with multiple option values' do
        let(:spree_variant) { create(:variant, option_values: option_values) }
        let!(:option_values) { [create(:option_value), create(:option_value), create(:option_value)] }

        subject { described_class.new(spree_variant, shopify_variant) }

        before do
          @shopify_variant = subject.perform
        end

        it 'fills all the shopify options values field' do
          option_values = spree_variant.option_values.all
          expect(@shopify_variant.option1).to eql(spree_variant.sku)
          expect(@shopify_variant.option2).to eql(option_values[0].name)
          expect(@shopify_variant.option3).to eql(option_values[1].name)
          expect(@shopify_variant.option4).to eql(option_values[2].name)
        end
      end

      context 'with no option values' do
        before do
          allow(spree_variant).to receive(:option_values).and_return([])
          @shopify_variant = subject.perform
        end

        it 'uses the sku as the unique option1 instead' do
          expect(@shopify_variant.option1).to eql(spree_variant.sku)
        end
      end
    end
  end
end
