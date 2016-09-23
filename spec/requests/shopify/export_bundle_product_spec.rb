require 'spec_helper'

describe 'Export a bundled Spree product with its assembly on Shopify', :vcr do
  include_context 'shopify_exporter_helpers'
  include_context 'shopify_helpers'
  include_context 'phase_2_bundle'

  let(:bundle) { create(:product, disable_shopify_sync: true) }
  let!(:parts) { (1..3).map { |i| create(:variant, sku: "SKUS-#{i}") } }
  let!(:bundle_parts) { bundle.parts << parts }

  before do
    bundle.master.update(sku: 'SKUS-M')
  end

  after do
    cleanup_shopify_product_from_spree!(bundle)
  end

  it 'creates a bundled product' do
    shopify_product = export_bundle!(bundle)
    expect(shopify_product.persisted?).to be_truthy
  end

  it 'creates a bundle product with the variant permutation' do
    shopify_product = export_bundle!(bundle)
    variant = shopify_product.variants.first

    expect(variant.option1).to eql('S')
    expect(variant.option2).to eql('S')
    expect(variant.option3).to eql('S')
  end

  it 'creates a bundle product with a proper variant sku' do
    shopify_product = export_bundle!(bundle)
    variant = shopify_product.variants.first

    expect(variant.sku).to eql('SKUS-M/SKUS-1/SKUS-2/SKUS-3')
  end

  it 'creates a bundle product with the option types' do
    shopify_product = export_bundle!(bundle)
    options = shopify_product.options

    expect(options.first.name).to eql('foo-size-1')
    expect(options.second.name).to eql('foo-size-2')
    expect(options.third.name).to eql('foo-size-3')
  end
end
