require 'spec_helper'

module Shopify
  RSpec.describe VariantConverter do
    include_context 'spree_builders'

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
      it { expect(subject[:product_id]).to eql(1) }
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
  end
end
