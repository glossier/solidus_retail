require 'spec_helper'

describe Shopify::ProductImageFactory do
  let(:spree_product) { create(:product, pos_product_id: '321') }

  before do
    allow_any_instance_of(Spree::Product).to receive(:export_to_shopify).and_return(true)
  end

  let!(:variant_image) { create(:image) }
  let!(:spree_variant) { create(:variant, product: spree_product, pos_variant_id: '123', images: [variant_image]) }

  subject { described_class.new(spree_variant) }

  context '.initialize' do
    it 'successfully does it\'s things' do
      expect(subject).to be_truthy
    end
  end

  context '.perform' do
    it 'returns shopify image object' do
      result = subject.perform
      expected_result = ShopifyAPI::Image

      expect(result).to be_an(expected_result)
    end

    context 'fills all the required fields' do
      before do
        @shopify_image = subject.perform
      end

      it { expect(@shopify_image.attachment).to eql(base64_encoded(spree_variant.default_pos_image)) }
      it { expect(@shopify_image.variant_ids).to eql([spree_variant.pos_variant_id]) }

      private

      def base64_encoded(image)
        bytes = File.open(image.attachment.path, "rb").read
        Base64.encode64(bytes)
      end
    end
  end
end
