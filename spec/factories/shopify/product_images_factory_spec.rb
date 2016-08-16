require 'spec_helper'

describe Shopify::ProductImagesFactory do
  let(:spree_product) { create(:product, pos_product_id: '321') }
  let!(:spree_variant) { create(:variant, product: spree_product, pos_variant_id: '123') }

  subject { described_class.new(spree_product) }

  before do
    allow_any_instance_of(Spree::Product).to receive(:export_to_shopify).and_return(true)
  end

  context '.initialize' do
    it 'successfully does it\'s things' do
      expect(subject).to be_truthy
    end
  end

  context '.perform' do
    it 'returns an array of shopify images' do
      result = subject.perform

      expect(result).to be_an(Array)
      expect(result.first).to be_an(ShopifyAPI::Image)
    end

    context 'fills all the required fields' do
      before do
        @shopify_image = subject.perform.first
      end

      xit { expect(@shopify_image.src).to eql(spree_variant.weight) }
      it { expect(@shopify_image.variant_ids).to eql([spree_variant.pos_variant_id]) }
      it { expect(@shopify_image.product_id).to eql(spree_product.pos_product_id) }
    end
  end
end
