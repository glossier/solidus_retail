require 'spec_helper'

module Shopify
  RSpec.describe VariantOperations do
    include_context 'spree_builders'

    subject { described_class }

    let(:variant) { build_spree_variant }
    let(:variant_updater_instance) { double('updater_instance', perform: true) }

    before do
      allow(Shopify::VariantUpdater).to receive(:new).and_return(variant_updater_instance)
    end

    describe 'when creating' do
      describe 'a regular variant' do
        it 'calls the variant exporter' do
          expect(variant_updater_instance).to receive(:perform)
          subject.create(spree_variant: variant)
        end
      end
    end

    describe 'when destroying' do
      describe 'a regular variant' do
        describe 'without a retail variant ID' do
          let(:variant) { build_spree_variant(pos_variant_id: nil) }

          it 'does not call find on the Shopify api' do
            expect(ShopifyAPI::Variant).not_to receive(:find_by_id)
            subject.destroy(spree_variant: variant)
          end
        end

        describe 'with a retail variant ID' do
          let(:variant) { build_spree_variant(pos_variant_id: '123321') }
          let(:shopify_variant) { double('shopify_variant', destroy: true) }

          describe 'when the variant is not found on Shopify' do
            before do
              expect(ShopifyAPI::Variant).to receive(:find_by_id).and_return(nil)
            end

            it 'does not call destroy on the variant Shopify api' do
              expect(shopify_variant).not_to receive(:destroy)
              subject.destroy(spree_variant: variant)
            end
          end

          describe 'when the variant is found on Shopify' do
            before do
              expect(ShopifyAPI::Variant).to receive(:find_by_id).and_return(shopify_variant)
            end

            it 'calls destroy on the variant Shopify api' do
              expect(shopify_variant).to receive(:destroy)
              subject.destroy(spree_variant: variant)
            end
          end
        end
      end
    end
  end
end
