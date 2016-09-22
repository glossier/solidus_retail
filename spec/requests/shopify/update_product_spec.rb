require 'spec_helper'

describe 'Update a Spree Product to Shopify', :vcr do
  include_context 'shopify_exporter_helpers'
  include_context 'shopify_helpers'

  let(:spree_product) { create(:product, name: 'Product Name') }

  after do
    cleanup_shopify_product_from_spree!(spree_product)
  end

  describe 'when the product does not exists on Shopify' do
    before do
      spree_product.master.update(sku: 'master-sku')
    end

    it 'creates a new product' do
      update_product!(spree_product)
      expect(subject).to be_truthy
    end

    it 'creates a product with the master variant' do
      shopify_product = export_product_and_variants!(spree_product)
      master_variant = shopify_product.variants.first
      expect(master_variant.sku).to eql('master-sku')
    end
  end

  describe 'when the product existed on Shopify but was deleted' do
    let!(:existing_product) { update_product!(spree_product) }
    let!(:old_pos_product_id) { spree_product.pos_product_id }

    before do
      cleanup_shopify_product!(existing_product)
    end

    it 'creates a new product' do
      shopify_product = update_product!(spree_product)

      expect(shopify_product.persisted?).to be_truthy
      expect(shopify_product.id).not_to eql(old_pos_product_id)
    end
  end

  describe 'when the product already exists on Shopify' do
    let!(:existing_product) { update_product!(spree_product) }

    it 'does not create a new product' do
      first_products_count = ShopifyAPI::Product.all.count
      expect(first_products_count).to be > 0

      update_product!(spree_product)

      second_products_count = ShopifyAPI::Product.all.count
      expect(first_products_count).to be(second_products_count)
    end

    it 'updates the existing product' do
      spree_product.update(name: 'new_name')
      shopify_product = update_product!(spree_product)

      expect(shopify_product.persisted?).to be_truthy
      expect(shopify_product.title).to eql('new_name')
    end
  end
end
