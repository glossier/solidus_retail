require 'spec_helper'

module Shopify
  RSpec.describe VariantPresenter do
    include Spree::Retail::PresenterHelper

    describe '.weight_unit' do
      class DummyClass < ActiveResource::Base; end
      subject { present(DummyClass.new, :variant) }

      it 'returns oz as the default unit' do
        result = subject.weight_unit
        expect(result).to eql('oz')
      end
    end

    describe '.default_pos_image' do
      let(:variant) { build(:variant) }
      let(:image) { build(:image) }

      before do
        variant.images << image
      end

      subject { present(variant, :variant) }

      it 'returns the first image of the variant' do
        result = subject.default_pos_image
        expect(result).to eql(variant.images.first)
      end
    end
  end
end
