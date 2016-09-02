require 'spec_helper'

describe 'Export a Spree Product that has no variants to Shopify' do
  include_context 'ignore_export_to_shopify'

  let(:spree_product) { create(:product) }
  subject { find_shopify_product(spree_product) }

  # TODO: Make this work with VCR instead of allowing net connect
  before do
    WebMock.allow_net_connect!
    export_product!(spree_product)
    spree_product.reload
  end

  after do
    cleanup_shopify_product!(subject)
    WebMock.disable_net_connect!
  end

  it 'exports the spree product' do
    expect(subject).to be_truthy
  end

  it 'associates the product with the master variant' do
    shopify_variant = subject.variants.first
    expected_result = spree_product.master.pos_variant_id

    expect(shopify_variant.id).to eql(expected_result)
  end

  it 'contains only the master variant' do
    variant_count = subject.variants.count
    expect(variant_count).to eql(1)
  end

  private

  def export_product!(spree_product)
    exporter = Shopify::ProductExporter.new(spree_product_id: spree_product.id)
    exporter.perform
  end

  def find_shopify_product(spree_product)
    ShopifyAPI::Product.find(spree_product.pos_product_id)
  end

  def cleanup_shopify_product!(product)
    product.destroy
  end
end
