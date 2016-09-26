require 'spec_helper'

describe 'Update a Spree Variant to Shopify', :vcr do
  include_context 'shopify_exporter_helpers'
  include_context 'shopify_helpers'

  let(:spree_product) { create(:product, name: 'Product Name') }
  let(:spree_variant) { create(:variant, product: spree_product, sku: 'susan_sku') }

  before do
    export_product_and_variants!(spree_product)
  end

  after do
    cleanup_shopify_product_from_spree!(spree_product)
  end

  it 'creates a new variant' do
    shopify_variant = update_variant!(spree_variant)

    expect(shopify_variant.persisted?).to be_truthy
  end

  it 'assigns the variant to the product' do
    update_variant!(spree_variant)
    shopify_product = find_shopify_product(spree_product)

    # First variant is the master variant
    associated_variant = shopify_product.variants.second
    expect(associated_variant.sku).to eql(spree_variant.sku)
  end

  describe 'when the variant existed on Shopify but was deleted' do
    let!(:old_pos_variant_id) { spree_variant.pos_variant_id }

    before do
      update_variant!(spree_variant)
      cleanup_shopify_variant_from_spree!(spree_variant)
    end

    it 'creates a new variant' do
      shopify_variant = update_variant!(spree_variant)

      expect(shopify_variant.persisted?).to be_truthy
      expect(shopify_variant.id).not_to eql(old_pos_variant_id)
    end
  end

  describe 'when the variant already exists on Shopify' do
    it 'does not create a new variant' do
      shopify_product = find_shopify_product(spree_product)
      first_associated_variant_count = shopify_product.variants.count
      expect(first_associated_variant_count).to be > 0

      update_variant!(spree_variant)

      shopify_product = find_shopify_product(spree_product)
      second_associated_variant_count = shopify_product.variants.count
      expect(first_associated_variant_count).to be(second_associated_variant_count)
    end

    it 'updates the existing variant' do
      spree_variant.update(sku: 'new_sku')
      shopify_variant = update_variant!(spree_variant)

      expect(shopify_variant.persisted?).to be_truthy
      expect(shopify_variant.sku).to eql('new_sku')
    end
  end
end
