require 'spec_helper'

describe 'Export a Spree Variant to Shopify' do
  include_context 'shopify_exporter_helpers'
  include_context 'shopify_helpers'

  let(:spree_product) { create(:product, name: 'Product Name') }
  let(:spree_variant) { create(:variant, product: spree_product, sku: 'susan') }
  subject { find_shopify_variant(spree_variant) }

  before do
    export_product!(spree_product)
  end

  after do
    cleanup_shopify_product_from_spree!(spree_product)
  end

  it 'creates a new variant' do
    export_variant!(spree_variant)
    expect(subject).to be_truthy
    cleanup_shopify_variant!(subject)
  end

  # describe 'when the product existed on Shopify but was deleted' do
  #   let!(:existing_product) { export_product!(spree_product) }
  #
  #   before do
  #     shopify_product = find_shopify_product(spree_product)
  #     cleanup_shopify_product!(shopify_product)
  #   end
  #
  #   it 'creates a new product' do
  #     export_product!(spree_product)
  #     expect(subject).to be_truthy
  #   end
  #
  #   after do
  #     cleanup_shopify_product!(subject)
  #   end
  # end
  #
  # describe 'when the product already exists on Shopify' do
  #   let!(:existing_product) { export_product!(spree_product) }
  #
  #   it 'does not create a new product' do
  #     products_count = ShopifyAPI::Product.all.count
  #     expect(products_count).to be > 0
  #
  #     export_product!(spree_product)
  #
  #     result = ShopifyAPI::Product.all.count
  #     expect(result).to be(products_count)
  #   end
  #
  #   it 'updates the existing product' do
  #     expect(subject.title).to eql(spree_product.name)
  #
  #     spree_product.update(name: 'new_name')
  #     export_product!(spree_product)
  #
  #     shopify_product = find_shopify_product(spree_product)
  #     expect(shopify_product.title).to eql('new_name')
  #   end
  #
  #   after do
  #     cleanup_shopify_product!(subject)
  #   end
  # end
end
