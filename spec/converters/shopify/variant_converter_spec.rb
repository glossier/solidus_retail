require 'spec_helper'

module Shopify
  RSpec.describe VariantConverter do
    include_context 'spree_builders'

    let(:spree_variant) { build_spree_variant }

    describe '.initialize' do
      subject { described_class.new(variant: spree_variant) }

      it 'returns an instance of a VariantConverter' do
        expect(subject).to be_a described_class
      end
    end

    describe '.to_hash' do
      let(:spree_product) { build_spree_product(id: 321, pos_product_id: 123) }
      let(:updated_at_date) { build_date_time(year: 2016, month: 1, day: 1, hour: 12, minute: 0, second: 0 ) }
      let(:spree_variant) do
        build_spree_variant(weight: 10, weight_unit: 'oz',
                            price: 23.32, sku: 'boy-brow',
                            product: spree_product,
                            updated_at: updated_at_date)
      end

      subject { described_class.new(variant: spree_variant).to_hash }

      it 'keeps the same weight value' do
        expect(subject[:weight]).to eql(10)
      end

      it 'uses the pos_product_id as the product_id' do
        expect(subject[:product_id]).to eql(123)
      end

      it 'keeps the same weight_unit value' do
        expect(subject[:weight_unit]).to eql('oz')
      end

      it 'keeps the same price value' do
        expect(subject[:price]).to eql(23.32)
      end

      it 'keeps the same sku value' do
        expect(subject[:sku]).to eql('boy-brow')
      end

      it 'keeps the same updated_at value' do
        expect(subject[:updated_at]).to eql(updated_at_date)
      end

      it 'uses the sku has the unique constraint value' do
        expect(subject[:option1]).to eql('boy-brow')
      end
    end
  end
end
