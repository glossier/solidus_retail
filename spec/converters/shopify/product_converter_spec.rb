require 'spec_helper'

module Shopify
  RSpec.describe ProductConverter do
    include_context 'ignore_export_to_shopify'

    let(:shopify_product) { ShopifyAPI::Product.new }
    let(:spree_master_variant) { create(:variant, pos_variant_id: '321') }
    let(:spree_product) { create(:product) }

    before do
      allow(spree_product).to receive(:master).and_return(spree_master_variant)
    end

    context '.initialize' do
      subject { described_class.new(spree_product: spree_product, shopify_product: shopify_product) }

      it "successfully does it's things" do
        expect(subject).to be_truthy
      end
    end

    context '.perform' do
      let(:variant_converter_instance) { double('variant_converter_instance', perform: true) }
      let(:variant_converter) { double('variant_convert', new: variant_converter_instance) }

      subject { described_class.new(spree_product: spree_product, shopify_product: shopify_product, variant_converter: variant_converter) }

      it 'returns a product shopify object' do
        result = subject.perform
        expected_result = ShopifyAPI::Product

        expect(result).to be_an(expected_result)
      end

      context 'with a product without variant' do
        let(:product_converter) { described_class.new(arguments) }

        context 'fills all the required fields' do
          let(:arguments) { { spree_product: spree_product, shopify_product: shopify_product } }
          subject { product_converter.perform }

          it { expect(subject.title).to eql(spree_product.name) }
          it { expect(subject.body_html).to be_truthy }
          it { expect(subject.created_at).to eql(spree_product.created_at) }
          it { expect(subject.updated_at).to eql(spree_product.updated_at) }
          it { expect(subject.published_at).to eql(spree_product.available_on) }
          it { expect(subject.handle).to eql(spree_product.slug) }

          context 'without specifying a vendor' do
            it { expect(subject.vendor).to eql('Default Vendor') }
          end

          context 'with a specified vendor' do
            let(:arguments) { { spree_product: spree_product, shopify_product: shopify_product, vendor: 'Glossier' } }
            subject { product_converter.perform }

            it { expect(subject.vendor).to eql('Glossier') }
          end
        end

        describe 'for master variant' do
          let(:shopify_variant) { double('shopify_variant') }
          let(:variant_converter_instance) { double('variant_converter_instance', perform: true) }
          let(:variant_converter) { double('variant_converter', new: variant_converter_instance ) }
          let(:variant_interface) { double('variant_interface', find: shopify_variant) }
          let(:arguments) do
            { spree_product: spree_product, shopify_product: shopify_product,
              variant_converter: variant_converter,
              variant_interface: variant_interface }
          end

          subject { product_converter }

          it 'calls the variant factory' do
            expect(variant_converter_instance).to receive(:perform).once
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
        let!(:spree_variant) { create(:variant, product: spree_product, pos_variant_id: '123') }
        let(:spree_product) { create(:product) }

        let(:shopify_variant) { double('shopify_variant') }
        let(:variant_converter_instance) { double('variant_converter_instance', perform: true) }
        let(:variant_converter) { double('variant_converter', new: variant_converter_instance ) }
        let(:variant_interface) { double('variant_interface', find: shopify_variant, new: shopify_variant) }
        let(:arguments) do
          { spree_product: spree_product, shopify_product: shopify_product,
            variant_converter: variant_converter,
            variant_interface: variant_interface }
        end

        subject { described_class.new(arguments) }

        it 'calls the variant factory' do
          expect(variant_converter_instance).to receive(:perform).twice
          subject.perform
        end

        it 'assigns the variant to the shopify instance' do
          shopify_product = subject.perform
          result = shopify_product.variants.count
          # NOTE: This would include the master variant as well
          expect(result).to eql(2)
        end

        context 'when shopify variant is not found' do
          let(:exception) { ActiveResource::ResourceNotFound.new(exception_error) }
          let(:exception_error) { double('err', code: '404') }
          let(:variant_interface) { double('variant_interface', new: true, find: exception) }

          subject { described_class.new(arguments) }

          before do
            allow(variant_interface).to receive(:find).and_raise(exception)
          end

          it 'generates a new shopify variant' do
            expect(variant_interface).to receive(:new).twice
            subject.perform
          end
        end
      end

      context 'with any types of products' do
        let(:arguments) { { spree_product: spree_product, shopify_product: shopify_product } }

        context 'that has' do
          context 'a single paragraph description' do
            let(:product_description) { "In the land between bare skin ..." }
            let(:spree_product) { create(:product, description: product_description) }
            subject { described_class.new(arguments) }

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
            subject { described_class.new(arguments) }

            it 'surrounds the product description with multiple paragraph tag' do
              product = subject.perform
              result = product.body_html

              expected_result = "<p>In the land between bare skin ...<br>\nComes in five super sheer</p>"
              expect(result).to eql(expected_result)
            end
          end
        end
      end

      describe 'logging' do
        let(:logger_instance) { double('logger') }

        context 'when shopify variant is not found' do
          let(:exception) { ActiveResource::ResourceNotFound.new(exception_error) }
          let(:exception_error) { double('err', code: '404') }
          let(:variant_interface) { double('variant_interface', new: true) }

          let(:arguments) do
            { spree_product: spree_product, shopify_product: shopify_product,
              variant_converter: variant_converter,
              variant_interface: variant_interface,
              logger: logger_instance }
          end

          subject { described_class.new(arguments) }

          before do
            allow(variant_interface).to receive(:find).and_raise(exception)
          end

          it 'logs an error' do
            expect(logger_instance).to receive(:error).once
            subject.perform
          end
        end
      end
    end
  end
end
