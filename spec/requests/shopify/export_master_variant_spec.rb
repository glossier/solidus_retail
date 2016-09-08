require 'spec_helper'

describe 'Export a Spree product with master variant to Shopify' do
  include_context 'shopify_exporter_helpers'
  include_context 'shopify_helpers'

  let(:spree_variant) { create(:variant, sku: 'master-sku') }
  let(:spree_product) { create(:product, name: 'Product Name') }

  before do
    allow(spree_product).to receive(:master).and_return(spree_variant)
  end

  after do
    cleanup_shopify_product_from_spree!(spree_product)
  end

  it 'creates a product with the associated master variant' do
    shopify_product = export_product!(spree_product)
    master_variant = shopify_product.variants.first
    require 'pry'; binding.pry
    expect(master_variant.sku).to eql('master-sku')
  end
end
