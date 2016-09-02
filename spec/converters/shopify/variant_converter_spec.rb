require 'spec_helper'

module Shopify
  RSpec.describe VariantConverter do
    include_context 'ignore_export_to_shopify'

    let(:shopify_variant) { ShopifyAPI::Variant.new }
    let(:spree_variant) { create(:variant) }

    let(:arguments) { { spree_variant: spree_variant, shopify_variant: shopify_variant } }
    subject { described_class.new(arguments) }

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
        let(:variant_converter) { described_class.new(arguments) }
        subject { variant_converter.perform }

        it { expect(subject.weight).to eql(spree_variant.weight) }
        it { expect(subject.price).to eql(spree_variant.price) }
        it { expect(subject.sku).to eql(spree_variant.sku) }
        it { expect(subject.updated_at).to eql(spree_variant.updated_at) }
        it { expect(subject.option1).to eql(spree_variant.sku) }

        context 'without specifying the weight unit' do
          it { expect(subject.weight_unit).to eql('oz') }
        end

        context 'with a specified weight unit' do
          let(:arguments) { { spree_variant: spree_variant, shopify_variant: shopify_variant, weight_unit: 'kg' } }
          subject { variant_converter.perform }

          it { expect(subject.weight_unit).to eql('kg') }
        end

        it 'uses the sku as the unique option1' do
          expect(subject.option1).to eql(spree_variant.sku)
        end
      end

      context 'with multiple option values' do
        let(:spree_variant) { create(:variant, option_values: option_values) }
        let!(:option_values) { [create(:option_value), create(:option_value), create(:option_value)] }

        let(:variant_converter) { described_class.new(arguments) }
        subject { variant_converter.perform }

        it 'fills all the shopify options values field' do
          option_values = spree_variant.option_values.all
          expect(subject.option2).to eql(option_values[0].name)
          expect(subject.option3).to eql(option_values[1].name)
          expect(subject.option4).to eql(option_values[2].name)
        end
      end
    end
  end
end
