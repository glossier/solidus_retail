require 'spec_helper'

describe Shopify::ProductExporter do
  let(:spree_product) { create(:product) }

  before do
    allow_any_instance_of(Spree::Product).to receive(:export_to_shopify).and_return(true)
    allow(Spree::Product).to receive(:find).and_return(spree_product)
  end

  context '.initialize' do
    subject { described_class.new(spree_product.id) }

    it 'successfully does it\'s things' do
      expect(subject).to be_truthy
    end
  end

  context '.perform' do
    let(:factory_class) { double('factory_class', new: factory_instance) }
    let(:factory_instance) { double('factory_instance', perform: shopify_product) }
    let(:logger_instance) { double('logger') }
    let(:shopify_product) { ShopifyProduct.new }
    let(:error_messages) { double('error_message', full_messages: ['error_1']) }

    before do
      allow(shopify_product).to receive(:id).and_return('123321')
      allow(shopify_product).to receive(:handle).and_return('slug')
      allow(shopify_product).to receive(:errors).and_return(error_messages)
      allow(shopify_product).to receive(:variants).and_return([])
    end

    context 'with an invalid shopify product' do
      subject { described_class.new(spree_product.id, factory_class) }

      before do
        allow(shopify_product).to receive(:save).and_return(false)
        allow(shopify_product).to receive(:persisted?).and_return(false)
      end

      it 'it does not persist the shopify product' do
        product = subject.perform
        result = product.persisted?
        expect(result).to be_falsey
      end
    end

    context 'with a valid shopify product' do
      subject { described_class.new(spree_product.id, factory_class) }

      before do
        allow(shopify_product).to receive(:save).and_return(true)
        allow(shopify_product).to receive(:persisted?).and_return(true)
      end

      it 'returns true if was successfull' do
        product = subject.perform
        result = product.persisted?
        expect(result).to be_truthy
      end

      it 'assigns the pos product id to the spree product' do
        subject.perform

        result = spree_product.pos_product_id
        expected_result = '123321'
        expect(result).to eql(expected_result)
      end

      context 'has variant images' do
        let!(:variant_image) { create(:image) }
        let!(:spree_variant) { create(:variant, images: [variant_image], product: spree_product) }
        let(:shopify_image) { ShopifyAPI::Image.new }

        it 'assigns the images to the shopify product' do
          shopify_product = subject.perform
          expect(shopify_product.images).not_to be_empty
        end

        it 'saves the shopify product with images' do
          expect(shopify_product).to receive(:save).twice
          subject.perform
        end
      end

      context 'has no variant images' do
        it 'does not assign the variant images' do
          shopify_product = subject.perform
          expect(shopify_product.images).to be_empty
        end

        it 'doesn\'t saves the shopify product' do
          expect(shopify_product).to receive(:save).once
          subject.perform
        end
      end
    end

    describe 'logging' do
      subject { described_class.new(spree_product.id, factory_class, logger_instance) }

      context 'when shopify product is invalid' do
        before do
          allow(shopify_product).to receive(:save).and_return(false)
          allow(logger_instance).to receive(:error).and_return(true)
        end

        it 'logs an error' do
          expect(logger_instance).to receive(:error).once
          subject.perform
        end
      end

      context 'when shopify product is valid' do
        before do
          allow(shopify_product).to receive(:save).and_return(true)
          allow(logger_instance).to receive(:info).and_return(true)
          allow_any_instance_of(Shopify::ProductExporter).to receive(:save_pos_product_id).and_return(true)
          allow_any_instance_of(Shopify::ProductExporter).to receive(:save_pos_variant_id).and_return(true)
        end

        it 'logs an info' do
          expect(logger_instance).to receive(:info).once
          subject.perform
        end
      end
    end
  end
end

class ShopifyProduct
  def initialize
    @images = []
  end

  attr_accessor :images
end
