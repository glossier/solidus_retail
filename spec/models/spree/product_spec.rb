require 'spec_helper'

module Spree
  RSpec.describe Product do
    describe 'properties' do
      subject { build_stubbed(:product, pos_product_id: '8675309') }

      it 'knows its retail product ID' do
        expect(subject.pos_product_id).to eq '8675309'
      end
    end
  end
end
