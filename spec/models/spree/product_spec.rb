require 'spec_helper'

module Spree
  RSpec.describe Product do
    let(:product_exporter_instance) { double('exporter_instance', perform: true) }

    before do
      allow(Shopify::ProductExporter).to receive(:new).and_return(product_exporter_instance)
    end

    describe 'when creating' do
      describe 'if the disable_shopify_sync is set to true' do
        subject { build(:product, disable_shopify_sync: true) }

        it 'does not call the create_shopify_product method' do
          expect(subject).not_to receive(:create_shopify_product)
          subject.save
        end
      end

      describe 'a regular product' do
        subject { build(:product) }

        it 'calls the product exporter' do
          expect(product_exporter_instance).to receive(:perform)
          subject.save
        end
      end
    end

    describe 'when destroying' do
      describe 'if the disable_shopify_sync is set to true' do
        subject { create(:product, disable_shopify_sync: true) }

        it 'does not call the destroy_shopify_product method' do
          expect(subject).not_to receive(:destroy_shopify_product)
          subject.destroy
        end
      end

      describe 'a regular product' do
        describe 'without a retail product ID' do
          subject { create(:product) }

          it 'does not call find on the Shopify api' do
            expect(ShopifyAPI::Product).not_to receive(:find_by_id)
            subject.destroy
          end
        end

        describe 'with a retail product ID' do
          subject { create(:product, pos_product_id: '123321') }
          let(:shopify_product) { double('shopify_product', destroy: true) }

          describe 'when the product is not found on Shopify' do
            before do
              expect(ShopifyAPI::Product).to receive(:find_by_id).and_return(nil)
            end

            it 'does not call destroy on the Product Shopify api' do
              expect(shopify_product).not_to receive(:destroy)
              subject.destroy
            end
          end

          describe 'when the product is found on Shopify' do
            before do
              expect(ShopifyAPI::Product).to receive(:find_by_id).and_return(shopify_product)
            end

            it 'calls destroy on the Product Shopify api' do
              expect(shopify_product).to receive(:destroy)
              subject.destroy
            end
          end
        end
      end
    end

    describe 'properties' do
      subject { build_stubbed(:product, pos_product_id: '8675309') }

      it 'knows its retail product ID' do
        expect(subject.pos_product_id).to eq '8675309'
      end
    end
  end
end
