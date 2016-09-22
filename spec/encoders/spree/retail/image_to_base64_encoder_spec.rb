require 'spec_helper'

module Spree
  module Retail
    RSpec.describe ImageToBase64Encoder do
      include_context 'spree_builders'

      let(:spree_image) { create(:image) }

      describe '.initialize' do
        subject { described_class.new(spree_image) }

        it 'returns an instance of the image to base64 encoder' do
          expect(subject).to be_a described_class
        end
      end

      describe 'encode' do
        describe 'with an image that has been saved locally' do
          let(:encoded_image_value) do
            bytes = File.open(spree_image.attachment.path, 'rb').read
            Base64.encode64(bytes)
          end

          subject { described_class.new(spree_image).encode }

          it 'returns the encoded value of the image' do
            expect(subject).to eql(encoded_image_value)
          end
        end
      end
    end
  end
end
