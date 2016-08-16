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
    let(:shopify_product) { double('shopify_product', id: '123321', handle: 'slug', errors: error_messages) }
    let(:error_messages) { double('error_message', full_messages: ['error_1']) }

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
        end

        it 'logs an info' do
          expect(logger_instance).to receive(:info).once
          subject.perform
        end
      end
    end
  end
end
