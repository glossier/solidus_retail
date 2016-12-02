require 'spec_helper'

module Spree
  RSpec.describe Product do
    describe 'properties' do
      subject { build_stubbed(:variant, pos_variant_id: '8675309') }

      it 'knows its retail variant ID' do
        expect(subject.pos_variant_id).to eq '8675309'
      end
    end
  end
end
