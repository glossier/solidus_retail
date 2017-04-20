require 'spec_helper'

module Shopify
  RSpec.describe GiftCardConverter do
    include_context 'spree_builders'

    let(:spree_gift_card) { build_spree_gift_card }

    describe '.initialize' do
      subject { described_class.new(gift_card: spree_gift_card) }

      it 'returns an instance of a GiftCardConverter' do
        expect(subject).to be_a described_class
      end
    end

    describe '.to_hash' do
      let(:spree_gift_card) { build_spree_gift_card(amount: 25, currency: 'CAD') }

      subject { described_class.new(gift_card: spree_gift_card).to_hash }

      it 'keeps the same amount as the initial value' do
        expect(subject[:initial_value]).to eql(25)
      end

      it 'keeps the same currency value' do
        expect(subject[:currency]).to eql('CAD')
      end
    end
  end
end
