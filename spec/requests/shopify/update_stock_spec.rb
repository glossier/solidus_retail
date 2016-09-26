require 'spec_helper'

describe 'Update the Shopify Variant quantity with the Spree Variant quantity', :vcr do
  include_context 'shopify_exporter_helpers'
  include_context 'shopify_helpers'

  let(:spree_product) { create(:product, name: 'Product Name', disable_shopify_sync: true) }
  let!(:spree_variant) { create(:variant, product: spree_product, sku: 'susan', disable_shopify_sync: true) }

  before do
    export_product_and_variants!(spree_product)
  end

  after do
    cleanup_shopify_product_from_spree!(spree_product)
  end

  it 'saves the variant new inventory quantity' do
    spree_variant.stock_items.first.set_count_on_hand(10)
    spree_variant.save
    spree_variant.reload

    shopify_variant = update_stock!(spree_variant)
    expect(shopify_variant.inventory_quantity).to eql(10)
  end
end
