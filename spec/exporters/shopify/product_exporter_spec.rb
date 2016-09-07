require 'spec_helper'

module Shopify
  RSpec.describe ProductExporter do
    include_context 'spree_builders'

    let(:spree_product) { build_spree_product }
    let(:product_klass) { double('product_klass', find: spree_product) }

    describe '.initialize' do
      subject { described_class.new(spree_product_id: spree_product.id, product_klass: product_klass) }

      it "successfully does it's things" do
        expect(subject).to be_a described_class
      end
    end
  end
end
