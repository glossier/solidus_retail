require 'spec_helper'

describe 'Export a Spree Product that has a variant to Shopify' do
  include_context 'ignore_export_to_shopify'

  let(:spree_product) { create(:product) }
  let!(:spree_variant) { create(:variant, product: spree_product) }

  # TODO: Make this work with VCR instead of allowing net connect
  before do
    WebMock.allow_net_connect!
    export_product!(spree_product)
    spree_product.reload
    spree_variant.reload
  end

  after do
    WebMock.disable_net_connect!
  end

  describe 'from the variant perspective' do
    subject { ShopifyAPI::Variant.find(spree_variant.pos_variant_id) }

    it 'generates the variant name when saving' do
      expect(subject.sku).to eql(spree_variant.sku)
    end

    it 'saves the variant' do
      expect(subject).to be_truthy
    end

    after do
      cleanup_shopify_product_from_variant!(subject)
    end
  end

  describe 'from the product perspective' do
    subject { ShopifyAPI::Product.find(spree_product.pos_product_id) }

    it 'saves the product' do
      expect(subject).to be_truthy
    end

    it 'associates the product with the variant' do
      variant_count = subject.variants.count

      # Actual variant + Master variant
      expect(variant_count).to eql(2)
    end

    after do
      cleanup_shopify_product!(subject)
    end
  end

  # context 'and variant has an image' do
  #   let!(:variant_image) { create(:image) }
  #   let!(:spree_variant) { create(:variant, images: [variant_image], product: spree_product) }
  #
  #   it 'saves the variant with the image' do
  #     subject.perform
  #     spree_variant.reload
  #     result = ShopifyAPI::Variant.find(spree_variant.pos_variant_id)
  #     expect(result).to be_truthy
  #     expect(result.image_id).not_to be_nil
  #   end
  # end

  private

  def export_product!(spree_product)
    exporter = Shopify::ProductExporter.new(spree_product_id: spree_product.id)
    exporter.perform
  end

  def cleanup_shopify_product_from_variant!(variant)
    product = ShopifyAPI::Product.find(variant.product_id)
    product.destroy
  end

  def cleanup_shopify_product!(product)
    product.destroy
  end
end
