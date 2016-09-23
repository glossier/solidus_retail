require 'spec_helper'

describe 'Export a Spree product with its variants on Shopify', :vcr do
  include_context 'shopify_exporter_helpers'
  include_context 'shopify_helpers'

  let!(:spree_variant) { create(:variant, sku: 'slave-sku', product: spree_product, disable_shopify_sync: true) }
  let(:spree_product) { create(:product, name: 'Product Name', disable_shopify_sync: true) }

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

  describe 'with a master variant containe one image' do
    let(:variant_image) { create(:image) }

    before do
      spree_product.master.images << variant_image
    end

    it 'creates a product with the associated variant images' do
      shopify_product = export_product_and_variants!(spree_product)
      expect(shopify_product.images.count).to eql(1)

      shopify_master_image = shopify_product.images.first
      spree_master_variant = spree_product.master

      expect(shopify_master_image.variant_ids).to eql([spree_master_variant.pos_variant_id.to_i])
    end
  end
end
