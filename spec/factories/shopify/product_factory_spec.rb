require 'spec_helper'

describe Shopify::ProductFactory do
  let(:shopify_product) { ShopifyAPI::Product.new }
  let(:spree_product) { create(:product) }

  subject { described_class.new(spree_product, shopify_product) }

  context '.initialize' do
    it 'successfully does it\'s things' do
      expect(subject).to be_truthy
    end
  end

  context '.perform' do
    it 'returns a shopify object' do
      result = subject.perform
      expected_result = ShopifyAPI::Product

      expect(result).to be_an(expected_result)
    end

    context 'fills all the required fields' do
      before do
        @shopify_product = subject.perform
      end

      it { expect(@shopify_product.title).to eql(spree_product.name) }
      it { expect(@shopify_product.created_at).to eql(spree_product.created_at) }
      it { expect(@shopify_product.updated_at).to eql(spree_product.updated_at) }
      it { expect(@shopify_product.published_at).to eql(spree_product.available_on) }
      it { expect(@shopify_product.vendor).to eql('Glossier') }
      it { expect(@shopify_product.handle).to eql(spree_product.slug) }

      context 'when a product has' do
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
