require 'spec_helper'

describe 'Export a Spree Product to Shopify' do
  before do
    allow_any_instance_of(Spree::Product).to receive(:export_to_shopify).and_return(true)
    WebMock.allow_net_connect!
  end

  after do
    WebMock.disable_net_connect!
  end

  context 'when product contains only the master variant' do
    let(:spree_product) { create(:product) }

    subject { Shopify::ProductExporter.new(spree_product.id) }

    before do
      subject.perform
      spree_product.reload
      @result = ShopifyAPI::Product.find(spree_product.pos_product_id)
    end

    it 'saves the product' do
      expect(@result).to be_truthy
      expect(@result.title).to eql(spree_product.name)
    end

    after do
      @result.destroy
    end
  end

  context 'when the product already exists on Shopify' do
    let(:spree_product) { create(:product) }
    let!(:existing_product) { subject.new(spree_product.id).perform }

    subject { Shopify::ProductExporter }

    it 'does not create a new product' do
      products_count = ShopifyAPI::Product.all.count
      subject.new(spree_product.id).perform

      result = ShopifyAPI::Product.all.count
      expect(result).to be(products_count)
    end

    it 'saves over the already existing product' do
      spree_product.reload
      product = ShopifyAPI::Product.find(spree_product.pos_product_id)
      expect(product.title).to eql(spree_product.name)

      spree_product.name = 'new_name'
      spree_product.save
      subject.new(spree_product.id).perform

      product = ShopifyAPI::Product.find(spree_product.pos_product_id)
      expect(product.title).to eql('new_name')
    end

    after do
      existing_product.destroy
    end
  end
end
