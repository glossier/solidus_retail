require 'spec_helper'

describe 'Export a Spree Product to Shopify' do
  include_context 'ignore_export_to_shopify'
  include_context 'shopify_exporter_helpers'
  include_context 'shopify_helpers'

  let(:spree_product) { create(:product) }
  subject { find_shopify_product(spree_product) }

  # TODO: Make this work with VCR instead of allowing net connect
  before do
    WebMock.allow_net_connect!
    export_product!(spree_product)
    spree_product.reload
  end

  after do
    WebMock.disable_net_connect!
  end

  describe 'when the product existed on Shopify but was deleted' do
    let!(:existing_product) { export_product!(spree_product) }

    it 'creates a new product' do
      old_product_id = spree_product.pos_product_id
      cleanup_shopify_product!(subject)
      export_product!(spree_product)
      cleanup_shopify_product!(spree_product)

      spree_product.reload
      new_product_id = spree_product.pos_product_id

      shopify_product = find_shopify_product(spree_product)
      expect(shopify_product).to be_truthy
      expect(new_product_id).not_to eql(old_product_id)

      cleanup_shopify_product!(shopify_product)
    end
  end

  describe 'when the product already exists on Shopify' do
    it 'does not create a new product' do
      products_count = ShopifyAPI::Product.all.count
      export_product!(spree_product)

      result = ShopifyAPI::Product.all.count
      expect(result).to be(products_count)
    end

    it 'updates the existing product' do
      expect(subject.title).to eql(spree_product.name)

      spree_product.name = 'new_name'
      spree_product.save
      export_product!(spree_product)

      shopify_product = find_shopify_product(spree_product)
      expect(shopify_product.title).to eql('new_name')
    end

    after do
      cleanup_shopify_product!(subject)
    end
  end
end
