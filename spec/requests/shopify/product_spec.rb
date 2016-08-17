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

    it 'generates the variant name when saving' do
      subject.perform
      spree_variant.reload
      result = ShopifyAPI::Variant.find(spree_variant.pos_variant_id)

      expect(result.sku).to eql(spree_variant.sku)

      # Shopify doesn't let us destroy a variant nor find its product
      product = ShopifyAPI::Product.find(result.product_id)
      product.destroy
    end

    it 'associates the product with the variant' do
      subject.perform
      spree_product.reload
      shopify_product = ShopifyAPI::Product.find(spree_product.pos_product_id)
      shopify_variant = shopify_product.variants.first
      spree_variant = spree_product.variants.first
      expect(shopify_variant).to be_truthy
      expect(shopify_variant.sku).to eql(spree_variant.sku)

      shopify_product.destroy
    end

    it 'saves the product' do
      subject.perform
      spree_product.reload
      result = ShopifyAPI::Product.find(spree_product.pos_product_id)

      expect(result).to be_truthy
      expect(result.title).to eql(spree_product.name)

      result.destroy
    end

    it 'saves the variant' do
      subject.perform
      spree_variant.reload
      result = ShopifyAPI::Variant.find(spree_variant.pos_variant_id)

      expect(result).to be_truthy
      expect(result.sku).to eql(spree_variant.sku)

      # Shopify doesn't let us destroy a variant nor find its product
      product = ShopifyAPI::Product.find(result.product_id)
      product.destroy
    end

    context 'and variant has an image' do
      let!(:variant_image) { create(:image) }
      let!(:spree_variant) { create(:variant, images: [variant_image], product: spree_product) }

      it 'saves the variant with the image' do
        subject.perform
        spree_variant.reload
        result = ShopifyAPI::Variant.find(spree_variant.pos_variant_id)
        expect(result).to be_truthy
        expect(result.image_id).not_to be_nil

        product = ShopifyAPI::Product.find(result.product_id)
        product.destroy
      end
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

    context 'when product contains variants' do
      let(:spree_product) { create(:product) }
      let!(:spree_variant) { create(:variant, product: spree_product) }
      let!(:existing_variant) { subject.new(spree_product.id).perform }

      it 'does not create a new variant' do
        variants_count = ShopifyAPI::Variant.all.count
        subject.new(spree_product.id).perform

        result = ShopifyAPI::Variant.all.count
        expect(result).to be(variants_count)
      end

      it 'saves over the already existing variant' do
        spree_variant.reload
        variant = ShopifyAPI::Variant.find(spree_variant.pos_variant_id)
        expect(variant.sku).to eql(spree_variant.sku)

        spree_variant.sku = 'new_sku'
        spree_variant.save
        subject.new(spree_product.id).perform

        variant = ShopifyAPI::Variant.find(spree_variant.pos_variant_id)
        expect(variant.sku).to eql('new_sku')
      end

      context 'and variant has an image' do
        let(:new_variant_image) { create(:image, attachment: open('http://placekitten.com/g/200/300')) }
        let(:existing_variant_image) { create(:image) }
        let!(:spree_variant_with_image) { create(:variant, images: [existing_variant_image], product: spree_product) }
        let!(:existing_variant_with_image) { subject.new(spree_product.id).perform }

        it 'replaces the image of the variant' do
          spree_variant_with_image.reload
          variant = ShopifyAPI::Variant.find(spree_variant_with_image.pos_variant_id)
          expect(variant.image_id).not_to be_nil

          first_image = ShopifyAPI::Image.find(variant.image_id, params: { product_id: variant.product_id })

          spree_variant_with_image.images.destroy_all
          spree_variant_with_image.images << new_variant_image
          spree_variant_with_image.save
          subject.new(spree_product.id).perform

          variant = ShopifyAPI::Variant.find(spree_variant_with_image.pos_variant_id)
          second_image = ShopifyAPI::Image.find(variant.image_id, params: { product_id: variant.product_id })
          expect(second_image.src).not_to eql(first_image.src)
        end
      end
    end

    after do
      existing_product.destroy
    end
  end
end
