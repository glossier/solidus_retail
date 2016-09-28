require 'spec_helper'

module Spree::Retail::Shopify
  RSpec.describe PartPresenter do
    include Spree::Retail::PresenterHelper
    include_context 'phase_2_bundle'

    subject { present(phase_2_part_1, :part) }

    describe 'without permutation' do
      it 'returns the sku of the part' do
        expect(subject.sku).to eql('boybrow')
      end
    end

    describe 'with permutation' do
      let(:permutation) do
        [{ sku: 'GBB100-SET',  option_type_text: 'brow shade',       option_value_text: 'Brown' },
         { sku: 'GML100-SET',  option_type_text: 'lip shade',        option_value_text: 'Cake' },
         { sku: 'GSC100-SET',  option_type_text: 'concealer shade',  option_value_text: 'Light' }]
      end

      before do
        subject.permutation = permutation
      end

      it 'forms the SKU with the master and the permutations' do
        expect(subject.sku).to eql('PHASE2/GBB100-SET/GML100-SET/GSC100-SET')
      end
    end
  end
end
