require 'spec_helper'

module Shopify
  RSpec.describe ImageConverter do
    let(:spree_variant) { build_spree_variant }

    describe '.initialize' do
      subject { described_class.new(spree_variant: spree_variant) }

      it "successfully does it's thing" do
        expect(subject).to be_a described_class
      end
    end

    describe '.to_hash' do
      subject { described_class.new(spree_variant: spree_variant).to_hash }

      it { expect(subject[:variant_ids]).to be_an(Array) }
      it { expect(subject[:variant_ids]).to eql(['pos_variant_id']) }

      describe 'when variant contains no images' do
        it { expect(subject[:attachment]).to be_nil }
      end

      describe 'when variant contains images' do
        let(:serializer_instance) { double('serializer_instance', serialize: 'serialized') }
        let(:image_serializer) { double('serializer', new: serializer_instance) }
        let(:spree_image) { double('spree_image') }
        let(:spree_variant_with_default_image) { build_spree_variant(default_pos_image: spree_image) }
        subject do
          described_class.new(spree_variant: spree_variant_with_default_image,
                              image_serializer: image_serializer).to_hash
        end

        it { expect(subject[:attachment]).to eq('serialized') }
      end
    end

    private

    # def base64_encoded(image)
    #   bytes = File.open(image.attachment.path, "rb").read
    #   Base64.encode64(bytes)
    # end

    def build_spree_variant(pos_variant_id: 'pos_variant_id',
                            weight: 'weight', weight_unit: 'weight_unit',
                            price: 'price', sku: 'sku',
                            default_pos_image: nil,
                            updated_at: build_date_time, option_values: [])

      variant = double(:spree_variant)

      allow(variant).to receive(:pos_variant_id).and_return(pos_variant_id)
      allow(variant).to receive(:weight).and_return(weight)
      allow(variant).to receive(:weight_unit).and_return(weight_unit)
      allow(variant).to receive(:price).and_return(price)
      allow(variant).to receive(:sku).and_return(sku)
      allow(variant).to receive(:updated_at).and_return(updated_at)
      allow(variant).to receive(:option_values).and_return(option_values)
      allow(variant).to receive(:default_pos_image).and_return(default_pos_image)

      variant
    end

    # def build_spree_image(instance: double(:spree_image_instance),
    #                       attachment: double(:spree_attachment, instance: instance))
    #
    #   double(:spree_image, attachment: attachment)
    # end

    def build_date_time(year: 1991, month: 3, day: 24)
      DateTime.new(year, month, day)
    end
  end
end
