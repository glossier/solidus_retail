require 'spec_helper'

describe Spree::Variant do
  let(:variant) { create(:variant) }

  describe 'method' do
    context 'default_pos_image' do
      let(:variant_image) { create(:image) }

      before do
        variant.images = [variant_image]
      end

      it 'returns the first variant image' do
        result = variant.default_pos_image
        expected_result = variant_image

        expect(result).to eql(expected_result)
      end
    end

    context 'default_pos_stock_location' do
      it 'returns the first stock location' do
        result = variant.default_pos_stock_location
        expected_result = Spree::StockLocation.first

        expect(result).to eql(expected_result)
      end
    end

    context 'count_on_hand_for' do
      let(:stock_location) { Spree::StockLocation.first }

      it 'returns the count_on_hand of the specified stock location' do
        result = variant.count_on_hand_for(stock_location)
        expected_result = variant.stock_items.find_by(stock_location_id: stock_location.id).count_on_hand

        expect(result).to eql(expected_result)
      end
    end
  end

  describe 'field' do
    it 'responds to variant_pos_id' do
      expect(variant).to respond_to(:pos_variant_id)
    end
  end
end
