require 'spec_helper'

describe 'Export a Spree Product to Shopify' do
  before do
    allow_any_instance_of(Spree::Product).to receive(:export_to_shopify).and_return(true)
    WebMock.allow_net_connect!
  end

  after do
    WebMock.disable_net_connect!
  end

  context 'when product contains has no variants' do
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

  context 'when product contains variants' do
    let(:spree_product) { create(:product) }
    let!(:spree_variant) { create(:variant, product: spree_product) }

    subject { Shopify::ProductExporter.new(spree_product.id) }

    before do
      subject.perform
    end

    it 'generates the variant name when saving' do
      spree_variant.reload
      result = ShopifyAPI::Variant.find(spree_variant.pos_variant_id)

      expect(result.title).to eql(spree_variant.option_values.first.name)

      # Shopify doesn't let us destroy a variant nor find its product
      product = ShopifyAPI::Product.find(result.product_id)
      product.destroy
    end

    it 'associates the product with the variant' do
      spree_product.reload
      shopify_product = ShopifyAPI::Product.find(spree_product.pos_product_id)
      shopify_variant = shopify_product.variants.first
      spree_variant = spree_product.variants.first
      expect(shopify_variant).to be_truthy
      expect(shopify_variant.title).to eql(spree_variant.option_values.first.name)

      shopify_product.destroy
    end

    it 'saves the product' do
      spree_product.reload
      result = ShopifyAPI::Product.find(spree_product.pos_product_id)

      expect(result).to be_truthy
      expect(result.title).to eql(spree_product.name)

      result.destroy
    end

    it 'saves the variant' do
      spree_variant.reload
      result = ShopifyAPI::Variant.find(spree_variant.pos_variant_id)

      expect(result).to be_truthy
      expect(result.title).to eql(spree_variant.option_values.first.name)

      # Shopify doesn't let us destroy a variant nor find its product
      product = ShopifyAPI::Product.find(result.product_id)
      product.destroy
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
