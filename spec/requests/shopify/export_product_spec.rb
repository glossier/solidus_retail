require 'spec_helper'

describe 'Export a Spree Product to Shopify' do
  include_context 'shopify_exporter_helpers'
  include_context 'shopify_helpers'

  let(:spree_product) { create(:product, name: 'Product Name') }

  it 'creates a new product' do
    export_product!(spree_product)
    expect(subject).to be_truthy
  end

  after do
    cleanup_shopify_product_from_spree!(spree_product)
  end

  describe 'when the product existed on Shopify but was deleted' do
    let!(:existing_product) { export_product!(spree_product) }

    before do
      cleanup_shopify_product!(existing_product)
    end

    it 'creates a new product' do
      shopify_product = export_product!(spree_product)

      expect(shopify_product.persisted?).to be_truthy
    end
  end

  describe 'when the product already exists on Shopify' do
    let!(:existing_product) { export_product!(spree_product) }

    it 'does not create a new product' do
      first_products_count = ShopifyAPI::Product.all.count
      expect(first_products_count).to be > 0

      export_product!(spree_product)

      second_products_count = ShopifyAPI::Product.all.count
      expect(first_products_count).to be(second_products_count)
    end

    it 'updates the existing product' do
      spree_product.update(name: 'new_name')
      shopify_product = export_product!(spree_product)

      expect(shopify_product.persisted?).to be_truthy
      expect(shopify_product.title).to eql('new_name')
    end
  end
end
