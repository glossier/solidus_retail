require 'spec_helper'

describe Spree::Product do
  describe 'callbacks' do
    let(:product) { build(:product) }

    context 'after_save' do
      it 'exports to shopify' do
        expect(product).to receive(:export_to_shopify).once

        product.save
      end
    end
  end

  describe 'field' do
    let(:product) { create(:product) }

    it 'responds to product_pos_id' do
      expect(product).to respond_to(:pos_product_id)
    end
  end
end
