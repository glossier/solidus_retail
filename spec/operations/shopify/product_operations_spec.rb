require 'spec_helper'

module Spree::Retail::Shopify
  RSpec.describe ProductOperations do
    include_context 'spree_builders'

    subject { described_class }

    describe 'when creating' do
      let(:product_exporter_instance) { double('exporter_instance', perform: true) }

      before do
        allow(ProductExporter).to receive(:new).and_return(product_exporter_instance)
      end

      describe 'a regular product' do
        let(:product) { build_spree_product }

        it 'calls the product exporter' do
          expect(product_exporter_instance).to receive(:perform)
          subject.create(spree_product: product)
        end
      end
    end

    describe 'when destroying' do
      describe 'a regular product' do
        describe 'without a retail product ID' do
          subject { create(:product) }

          it 'does not call find on the Shopify api' do
            expect(ShopifyAPI::Product).not_to receive(:find_by_id)
            subject.destroy
          end
        end

        describe 'with a retail product ID' do
          let(:product) { build_spree_product(pos_product_id: '123321') }
          let(:shopify_product) { double('shopify_product', destroy: true) }

          describe 'when the product is not found on Shopify' do
            before do
              expect(ShopifyAPI::Product).to receive(:find_by_id).and_return(nil)
            end

            it 'does not call destroy on the Product Shopify api' do
              expect(shopify_product).not_to receive(:destroy)
              subject.destroy(spree_product: product)
            end
          end

          describe 'when the product is found on Shopify' do
            before do
              expect(ShopifyAPI::Product).to receive(:find_by_id).and_return(shopify_product)
            end

            it 'calls destroy on the Product Shopify api' do
              expect(shopify_product).to receive(:destroy)
              subject.destroy(spree_product: product)
            end
          end
        end
      end
    end
  end
end
