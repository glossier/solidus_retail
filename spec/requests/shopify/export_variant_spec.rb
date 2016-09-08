require 'spec_helper'

describe 'Export a Spree Variant to Shopify' do
  include_context 'shopify_exporter_helpers'
  include_context 'shopify_helpers'

  let(:spree_product) { create(:product, name: 'Product Name') }
  let(:spree_variant) { create(:variant, product: spree_product, sku: 'susan') }

  before do
    export_product!(spree_product)
  end

  after do
    # This will auto-destroy the variants, due to the shopify associations.
    cleanup_shopify_product_from_spree!(spree_product)
  end

  it 'creates a new variant' do
    shopify_variant = export_variant!(spree_variant)

    expect(shopify_variant.persisted?).to be_truthy
  end

  it 'assigns the variant to the product' do
    export_variant!(spree_variant)
    shopify_product = find_shopify_product(spree_product)

    # First variant is the master variant
    associated_variant = shopify_product.variants.second
    expect(associated_variant.sku).to eql(spree_variant.sku)
  end

  describe 'when the variant existed on Shopify but was deleted' do
    let!(:existing_variant) { export_variant!(spree_variant) }

    before do
      cleanup_shopify_variant!(existing_variant)
    end

    it 'creates a new variant' do
      shopify_variant = export_variant!(spree_variant)
      expect(shopify_variant.persisted?).to be_truthy
    end
  end

  describe 'when the variant already exists on Shopify' do
    let!(:existing_variant) { export_variant!(spree_variant) }

    it 'does not create a new variant' do
      shopify_product = find_shopify_product(spree_product)
      first_associated_variant_count = shopify_product.variants.count
      expect(first_associated_variant_count).to be > 0

      export_variant!(spree_variant)

      shopify_product = find_shopify_product(spree_product)
      second_associated_variant_count = shopify_product.variants.count
      expect(first_associated_variant_count).to be(second_associated_variant_count)
    end

    it 'updates the existing variant' do
      spree_variant.update(sku: 'new_sku')
      shopify_variant = export_variant!(spree_variant)

      expect(shopify_variant.persisted?).to be_truthy
      expect(shopify_variant.sku).to eql('new_sku')
    end
  end
end
