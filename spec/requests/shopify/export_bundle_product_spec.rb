require 'spec_helper'

describe 'Export a bundled Spree product with its assembly on Shopify' do
  include_context 'shopify_exporter_helpers'
  include_context 'shopify_helpers'
  include_context 'phase_2_bundle'

  let(:bundle) { create(:product) }
  let!(:parts) { (1..3).map { create(:variant) } }
  let!(:bundle_parts) { bundle.parts << parts }

  after do
    cleanup_shopify_product_from_spree!(bundle)
  end

  it 'creates a bundled product' do
    shopify_product = export_bundle!(bundle)

    expect(shopify_product.persisted?).to be_truthy
  end

  it 'creates a bundle product with the variant permutations' do
  end
end
