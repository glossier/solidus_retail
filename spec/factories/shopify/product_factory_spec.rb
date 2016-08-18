require 'spec_helper'

describe Shopify::ProductFactory do
  let(:shopify_product) { ShopifyAPI::Product.new }
  let(:spree_product) { create(:product) }

  subject { described_class.new(spree_product, shopify_product) }

  before do
    allow_any_instance_of(Spree::Product).to receive(:export_to_shopify).and_return(true)
  end

  context '.initialize' do
    it 'successfully does it\'s things' do
      expect(subject).to be_truthy
    end
  end

  context '.perform' do
    let(:variant_factory) { double('variant_factory_instance', perform: true) }

    before do
      allow(Shopify::VariantFactory).to receive(:new).and_return(variant_factory)
    end

    it 'returns a product shopify object' do
      result = subject.perform
      expected_result = ShopifyAPI::Product

      expect(result).to be_an(expected_result)
    end

    context 'with a product without variant' do
      context 'fills all the required fields' do
        before do
          @shopify_product = subject.perform
        end

        it { expect(@shopify_product.title).to eql(spree_product.name) }
        it { expect(@shopify_product.body_html).to be_truthy }
        it { expect(@shopify_product.created_at).to eql(spree_product.created_at) }
        it { expect(@shopify_product.updated_at).to eql(spree_product.updated_at) }
        it { expect(@shopify_product.published_at).to eql(spree_product.available_on) }
        it { expect(@shopify_product.vendor).to eql('Glossier') }
        it { expect(@shopify_product.handle).to eql(spree_product.slug) }
      end

      describe 'for master variant' do
        it 'calls the variant factory' do
          expect(variant_factory).to receive(:perform).once
          subject.perform
        end

        it 'assigns the variant to the shopify instance' do
          shopify_product = subject.perform
          result = shopify_product.variants.count
          expect(result).to eql(1)
        end
      end
    end

    context 'with a product with variants' do
      let!(:spree_variant) { create(:variant, product: spree_product) }
      let(:spree_product) { create(:product) }
      subject { described_class.new(spree_product, shopify_product) }

      it 'calls the variant factory' do
        expect(variant_factory).to receive(:perform).twice
        subject.perform
      end

      it 'assigns the variant to the shopify instance' do
        shopify_product = subject.perform
        result = shopify_product.variants.count
        # Including the master variant
        expect(result).to eql(2)
      end
    end

    context 'with any types of products' do
      context 'that has' do
        context 'a single paragraph description' do
          let(:product_description) { "In the land between bare skin ..." }
          let(:spree_product) { create(:product, description: product_description) }
          subject { described_class.new(spree_product, shopify_product) }

          it 'surrounds the product description with a paragraph tag' do
            product = subject.perform
            result = product.body_html

            expected_result = "<p>In the land between bare skin ...</p>"
            expect(result).to eql(expected_result)
          end
        end

        context 'with multiple paragraphs description' do
          let(:product_description) do
            "In the land between bare skin ...
Comes in five super sheer"
          end
          let(:spree_product) { create(:product, description: product_description) }
          subject { described_class.new(spree_product, shopify_product) }

          it 'surrounds the product description with multiple paragraph tag' do
            product = subject.perform
            result = product.body_html

            expected_result = "<p>In the land between bare skin ...</p><p>Comes in five super sheer</p>"
            expect(result).to eql(expected_result)
          end
        end
      end
    end
  end
end
