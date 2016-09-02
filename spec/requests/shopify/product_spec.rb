require 'spec_helper'

describe 'Export a Spree Product to Shopify' do
  include_context 'ignore_export_to_shopify'

  context 'when the variant existed but was deleted' do
    let(:spree_product) { create(:product) }
    let!(:existing_product) { subject.new(spree_product.id).perform }

    subject { Shopify::ProductExporter }

    it 'creates a new variant' do
      spree_variant = spree_product.master

      spree_variant.reload
      variant = ShopifyAPI::Variant.find(spree_variant.pos_variant_id)
      product = ShopifyAPI::Product.find(variant.product_id)
      product.destroy

      subject.new(spree_product.id).perform

      spree_variant.reload
      result = ShopifyAPI::Variant.find(spree_variant.pos_variant_id)
      expect(result).to be_truthy

      product = ShopifyAPI::Product.find(result.product_id)
      product.destroy
    end
  end

  context 'when the product already exists on Shopify' do
    let(:spree_product) { create(:product) }
    let!(:existing_product) { subject.new(spree_product.id).perform }

    subject { Shopify::ProductExporter }


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
