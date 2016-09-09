require 'spec_helper'

describe 'Export a Spree product with its variants on Shopify' do
  include_context 'shopify_exporter_helpers'
  include_context 'shopify_helpers'

  let!(:spree_variant) { create(:variant, sku: 'slave-sku', product: spree_product) }
  let(:spree_product) { create(:product, name: 'Product Name') }

  before do
    spree_product.master.update(sku: 'master-sku')
  end

  after do
    cleanup_shopify_product_from_spree!(spree_product)
  end

  it 'creates a product with the associated variant' do
    shopify_product = export_product_and_variants!(spree_product)
    master_variant = shopify_product.variants.first
    expect(master_variant.sku).to eql('master-sku')

    slave_variant = shopify_product.variants.second
    expect(slave_variant.sku).to eql('slave-sku')
  end
end
