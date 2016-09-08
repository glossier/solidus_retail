require 'spec_helper'

# Given a Spree product
# When I reun the ProductExporter
# And I visit my Shopify admin
# Then I should see an equivalent Shopify product

module Shopify
  RSpec.describe ProductExporter do
    include_context 'spree_builders'

    describe '#initialize' do
      it "returns an instance of the product exporter" do
        expect(subject).to be_a described_class
      end
    end

    let(:product_factory) { double(:factory) }
    let(:spree_product) { build_spree_product(name: 'Boy Brow') }
    let(:spree_klass) { double(:spree_klass, find: spree_product) }

    describe '#perform' do
      context "when an equivalent Shopify product already exists" do
      end

      context "when an equivalent Shopify product doesn't exist" do
        subject { described_class.new(spree_product_id: spree_product.id, product_klass: spree_klass) }

        it 'creates a Shopify product' do
          expect(product_factory).to receive(:new).with(name: "Boy Brow")
          subject.perform
        end

        xit 'saves the shopify product id back to the spree product' do
        end
      end

      context "when a Shopify product existed but doesn't exist anymore" do
        xit 'saves the shopify product id back to the spree product' do
        end
      end
    end
  end

  #   include_context 'spree_builders'
  #
  #   let(:spree_product) { build_spree_product }
  #   let(:product_klass) { double('product_klass', find: spree_product) }
  #
  #
  #   describe '.initialize' do
  #     subject { described_class.new(spree_product_id: spree_product.id, product_klass: product_klass) }
  #
  #     it "successfully does it's things" do
  #       expect(subject).to be_a described_class
  #     end
  #   end
  #
  #   describe '.perform' do
  #   end
  # end
end
