require 'spec_helper'

module Shopify
  RSpec.describe VariantConverter do
    let(:spree_variant) { build_spree_variant }

    describe '.initialize' do
      subject { described_class.new(spree_variant) }

      it "successfully does it's thing" do
        expect(subject).to be_a described_class
      end
    end

    describe '.to_hash' do
      subject { described_class.new(spree_variant).to_hash }

      it { expect(subject[:weight]).to eql('weight') }
      it { expect(subject[:weight_unit]).to eql('weight_unit') }
      it { expect(subject[:price]).to eql('price') }
      it { expect(subject[:sku]).to eql('sku') }
      it { expect(subject[:updated_at]).to eql(build_date_time) }

      it 'has the unique constraint value' do
        expect(subject[:option1]).to eql('sku')
      end

      describe 'when it has option_values' do
        let(:option_value_1) { build_spree_option_value(name: 'name1') }
        let(:option_value_2) { build_spree_option_value(name: 'name2') }
        let(:option_values) { [option_value_1, option_value_2] }
        let(:spree_variant_with_options) { build_spree_variant(option_values: option_values) }
        subject { described_class.new(spree_variant_with_options).to_hash }

        it { expect(subject[:option2]).to eql('name1') }
        it { expect(subject[:option3]).to eql('name2') }
      end
    end

    private

    def build_spree_variant(weight: 'weight', weight_unit: 'weight_unit',
                            price: 'price', sku: 'sku',
                            updated_at: build_date_time, option_values: [])

      variant = double(:spree_variant)

      allow(variant).to receive(:weight).and_return(weight)
      allow(variant).to receive(:weight_unit).and_return(weight_unit)
      allow(variant).to receive(:price).and_return(price)
      allow(variant).to receive(:sku).and_return(sku)
      allow(variant).to receive(:updated_at).and_return(updated_at)
      allow(variant).to receive(:option_values).and_return(option_values)

      variant
    end

    def build_spree_option_value(name: 'name', value: 'value')
      option = double(:spree_option)

      allow(option).to receive(:name).and_return(name)
      allow(option).to receive(:value).and_return(value)

      option
    end

    def build_date_time(year: 1991, month: 3, day: 24)
      DateTime.new(year, month, day)
    end
  end
end

# describe 'with multiple option values' do
#   let(:spree_variant) { create(:variant, option_values: option_values) }
#   let!(:option_values) { [create(:option_value), create(:option_value), create(:option_value)] }
#
#   let(:variant_converter) { described_class.new(arguments) }
#   subject { variant_converter.perform }
#
#   it 'fills all the shopify options values field' do
#     option_values = spree_variant.option_values.all
#     expect(subject.option2).to eql(option_values[0].name)
#     expect(subject.option3).to eql(option_values[1].name)
#     expect(subject.option4).to eql(option_values[2].name)
#   end
# end
#     end
#   end
# end
