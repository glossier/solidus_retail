require 'spec_helper'

module Shopify
  RSpec.describe ProductExporter do
    include_context 'ignore_export_to_shopify'

    let(:spree_product) { create(:product) }

    context '.initialize' do
      subject { described_class.new(spree_product_id: spree_product.id) }

      it "successfully does it\'s things" do
        expect(subject).to be_truthy
      end
    end

    context '.perform' do
      let(:factory_instance) { double('factory_instance', perform: shopify_product) }
      let(:factory_class) { double('factory_class', new: factory_instance) }

      context 'with an invalid shopify product' do
        let(:error_messages) { double('error_message', full_messages: ['error_1']) }
        let(:shopify_product) { double('shopify_product', save: false, persisted?: false, handle: 'slug', errors: error_messages) }
        subject { described_class.new(spree_product_id: spree_product.id, factory: factory_class) }

        it 'it does not persist the shopify product' do
          product = subject.perform
          result = product.persisted?
          expect(result).to be_falsey
        end
      end

      context 'with a valid shopify product' do
        subject { described_class.new(spree_product_id: spree_product.id, factory: factory_class) }
        let(:shopify_product) { ShopifyProduct.new }

        before do
          allow(shopify_product).to receive(:handle).and_return('slug')
          allow(shopify_product).to receive(:id).and_return('123321')
          allow(shopify_product).to receive(:save).and_return(true)
          allow(shopify_product).to receive(:persisted?).and_return(true)
          allow(shopify_product).to receive(:variants).and_return([])
        end

        it 'returns true if was successfull' do
          product = subject.perform
          result = product.persisted?
          expect(result).to be_truthy
        end

        it 'assigns the pos product id to the spree product' do
          subject.perform

          result = spree_product.pos_product_id
          spree_product.reload
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

        context 'when shopify product is not found' do
          let(:spree_product) { double('spree_product', id: '123', pos_product_id: '321', slug: 'handle') }

          before do
            allow(Spree::Product).to receive(:find).and_return(spree_product)
            allow(ShopifyAPI::Product).to receive(:find).and_raise(exception)
          end

          it 'generates a new shopify product' do
            expect(ShopifyAPI::Product).to receive(:new).once
            described_class.new(spree_product.id, factory_class, logger_instance)
          end
        end
      end

      describe 'logging' do
        subject { described_class.new(spree_product_id: spree_product.id, factory: factory_class, logger: logger_instance) }

        context 'when shopify product is invalid' do
          let(:logger_instance) { double('logger', error: true) }
          let(:error_messages) { double('error_message', full_messages: ['error_1']) }
          let(:shopify_product) { double('shopify_product', save: false, errors: error_messages) }

          before do
            allow(shopify_product).to receive(:handle).and_return('slug')
            allow(shopify_product).to receive(:id).and_return('123321')
          end

          it 'logs an error' do
            expect(logger_instance).to receive(:error).once.with(an_instance_of(String))
            subject.perform
          end
        end

        context 'when shopify product is valid' do
          let(:logger_instance) { double('logger', info: true) }
          let(:shopify_product) { ShopifyProduct.new }

          before do
            allow(shopify_product).to receive(:handle).and_return('slug')
            allow(shopify_product).to receive(:id).and_return('123321')
            allow(shopify_product).to receive(:save).and_return(true)
            allow(shopify_product).to receive(:persisted?).and_return(true)
            allow(shopify_product).to receive(:variants).and_return([])
          end

          it 'logs an info' do
            expect(logger_instance).to receive(:info).once.with(an_instance_of(String))
            subject.perform
          end
        end

        context 'when shopify product is not found' do
          let(:logger_instance) { double('logger', error: true) }
          let(:exception_error) { double('err', code: '404') }
          let(:exception) { ActiveResource::ResourceNotFound.new(exception_error) }
          let(:shopify_product) { double('shopify_product') }

          before do
            allow(ShopifyAPI::Product).to receive(:find).and_raise(exception)
          end

          it 'logs an error' do
            expect(logger_instance).to receive(:error).once.with(an_instance_of(String))
            subject.perform
          end
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
