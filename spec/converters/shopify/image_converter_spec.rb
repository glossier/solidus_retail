require 'spec_helper'

module Shopify
  RSpec.describe ImageConverter do
    include_context 'spree_builders'

    let(:spree_image) { create(:image) }
    let(:pos_variant_id) { 'kittens' }

    describe '.initialize' do
      subject { described_class.new(image: spree_image, pos_variant_id: pos_variant_id) }

      it 'returns an instance of the image converter' do
        expect(subject).to be_a described_class
      end
    end

    describe '.to_hash' do
      let(:base64_image) { 'hello darkness my old friend' }
      let(:image_encoder_instance) { double('image_encoder_instance', encode: base64_image) }
      let(:image_encoder_klass) { double('image_encoder_klass', new: image_encoder_instance ) }

      subject { described_class.new(image: spree_image, pos_variant_id: pos_variant_id, image_encoder: image_encoder_klass).to_hash }

      it 'contains the variant_id' do
        expect(subject[:variant_ids]).to eql(['kittens'])
      end

      it 'contains the attachment' do
        expect(subject[:attachment]).to eql(base64_image)
      end
    end
  end
end
