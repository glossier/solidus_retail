require 'spec_helper'

module Spree
  RSpec.describe Variant do
    let(:product_exporter_instance) { double('exporter_instance', perform: true) }
    let(:variant_updater_instance) { double('updater_instance', perform: true) }

    before do
      allow(Shopify::ProductExporter).to receive(:new).and_return(product_exporter_instance)
      allow(Shopify::VariantUpdater).to receive(:new).and_return(variant_updater_instance)
    end

    describe 'when creating' do
      describe 'if the disable_shopify_sync is set to true' do
        subject { build(:variant, disable_shopify_sync: true) }

        it 'does not call the create_shopify_variant method' do
          expect(subject).not_to receive(:create_shopify_variant)
          subject.save
        end
      end

      describe 'a regular variant' do
        subject { build(:variant) }

        it 'calls the variant exporter' do
          expect(variant_updater_instance).to receive(:perform)
          subject.save
        end
      end
    end

    describe 'when destroying' do
      describe 'if the disable_shopify_sync is set to true' do
        subject { create(:variant, disable_shopify_sync: true) }

        it 'does not call the destroy_shopify_variant method' do
          expect(subject).not_to receive(:destroy_shopify_variant)
          subject.destroy
        end
      end

      describe 'a regular variant' do
        describe 'without a retail variant ID' do
          subject { create(:variant) }

          it 'does not call find on the Shopify api' do
            expect(ShopifyAPI::Variant).not_to receive(:find_by_id)
            subject.destroy
          end
        end

        describe 'with a retail variant ID' do
          subject { create(:variant, pos_variant_id: '123321') }
          let(:shopify_variant) { double('shopify_variant', destroy: true) }

          describe 'when the variant is not found on Shopify' do
            before do
              expect(ShopifyAPI::Variant).to receive(:find_by_id).and_return(nil)
            end

            it 'does not call destroy on the variant Shopify api' do
              expect(shopify_variant).not_to receive(:destroy)
              subject.destroy
            end
          end

          describe 'when the variant is found on Shopify' do
            before do
              expect(ShopifyAPI::Variant).to receive(:find_by_id).and_return(shopify_variant)
            end

            it 'calls destroy on the variant Shopify api' do
              expect(shopify_variant).to receive(:destroy)
              subject.destroy
            end
          end
        end
      end
    end

    describe 'properties' do
      subject { build_stubbed(:variant, pos_variant_id: '8675309') }

      it 'knows its retail variant ID' do
        expect(subject.pos_variant_id).to eq '8675309'
      end
    end
  end
end
