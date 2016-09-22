require 'spec_helper'

module Shopify
  RSpec.describe PartConverter do
    include_context 'phase_2_bundle'

    let(:permutation) do
      [{ sku: 'GBB100-SET',  option_type_text: 'brow shade',       option_value_text: 'Brown' },
       { sku: 'GML100-SET',  option_type_text: 'lip shade',        option_value_text: 'Cake' },
       { sku: 'GSC100-SET',  option_type_text: 'concealer shade',  option_value_text: 'Light' }]
    end

    describe '.initialize' do
      subject { described_class.new(part: phase_2_part_1, permutation: permutation) }

      it 'returns and instance of Part Converter' do
        expect(subject).to be_a described_class
      end
    end

    describe '.to_hash' do
      subject { described_class.new(part: phase_2_part_1, permutation: permutation).to_hash }

      it 'keeps the same weight value' do
        expect(subject[:weight]).to eql(10)
      end

      it 'keeps the same weight_unit value' do
        expect(subject[:weight_unit]).to eql('oz')
      end

      it 'keeps the same price value' do
        expect(subject[:price]).to eql(10.45)
      end

      it 'keeps the same sku value' do
        expect(subject[:sku]).to eql('boybrow')
      end

      it 'keeps the same updated_at value' do
        expect(subject[:updated_at]).to eql(phase_2_part_1.updated_at)
      end

      it 'contains all the option values' do
        expect(subject[:option1]).to eql('Brown')
        expect(subject[:option2]).to eql('Cake')
        expect(subject[:option3]).to eql('Light')
      end
    end
  end
end
