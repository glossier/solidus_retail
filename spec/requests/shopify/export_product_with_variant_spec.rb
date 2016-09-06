require 'spec_helper'

describe 'Export a Spree Product that has a variant to Shopify' do
  include_context 'ignore_export_to_shopify'
  include_context 'shopify_exporter_helpers'
  include_context 'shopify_helpers'

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
    subject { find_shopify_variant(spree_variant) }

    it 'saves the variant' do
      expect(subject).to be_truthy
    end

    after do
      cleanup_shopify_product_from_variant!(subject)
    end
  end

  describe 'from the product perspective' do
    subject { find_shopify_product(spree_product) }

    it 'saves the product' do
      expect(subject).to be_truthy
    end

    it 'contains the master variant and the regular variant' do
      variant_count = subject.variants.count
      expect(variant_count).to eql(2)
    end

    it 'associates the product with the variant' do
      find_shopify_variant = subject.variants.second
      expected_result = spree_product.variants.first.pos_variant_id

      expect(find_shopify_variant.id).to eql(expected_result.to_i)
    end

    after do
      cleanup_shopify_product!(subject)
    end
  end

  describe 'when the variant existed but was deleted' do
    subject { find_shopify_variant(spree_variant) }

    it 'creates a new variant' do
      old_variant_id = spree_variant.pos_variant_id
      cleanup_shopify_product_from_variant!(subject)
      export_product!(spree_product)

      spree_variant.reload
      new_variant_id = spree_variant.pos_variant_id

      shopify_variant = find_shopify_variant(spree_variant)
      expect(shopify_variant).to be_truthy
      expect(new_variant_id).not_to eql(old_variant_id)

      cleanup_shopify_product_from_variant!(shopify_variant)
    end
  end

  describe 'when the variant has an image' do
    let(:variant_image) { create(:image) }

    subject { find_shopify_variant(spree_variant) }

    before do
      spree_variant.images = [variant_image]
      spree_variant.save
      export_product!(spree_product)
    end

    it 'saves the variant with the image' do
      result = find_shopify_variant(spree_variant)
      expect(result.image_id).not_to be_nil
    end

    after do
      cleanup_shopify_product_from_variant!(subject)
    end
  end

  describe 'when the variant already exists on Shopify' do
    subject { find_shopify_variant(spree_variant) }

    it 'does not create a new variant' do
      variants_count = ShopifyAPI::Variant.all.count
      export_product!(spree_product)

      result = ShopifyAPI::Variant.all.count
      expect(result).to be(variants_count)
    end

    it 'updates the existing variant' do
      expect(subject.sku).to eql(spree_variant.sku)

      spree_variant.sku = 'new_sku'
      spree_variant.save
      export_product!(spree_product)

      variant = find_shopify_variant(spree_variant)
      expect(variant.title).to eql('new_sku')
    end

    describe 'when the variant has an image' do
      let(:existing_variant_image) { create(:image) }
      let(:new_variant_image) { create(:image, attachment: open('http://placekitten.com/g/200/300')) }

      before do
        spree_variant.images = [existing_variant_image]
        spree_variant.save
        export_product!(spree_product)
      end

      it 'replaces the image of the variant' do
        shopify_variant = find_shopify_variant(spree_variant)
        expect(shopify_variant.image_id).not_to be_nil

        first_image = find_shopify_image(shopify_variant)
        reset_image_of_variant(spree_variant, new_variant_image)
        export_product!(spree_product)

        shopify_variant = find_shopify_variant(spree_variant)
        second_image = find_shopify_image(shopify_variant)

        expect(second_image.src).not_to eql(first_image.src)
      end

      private

      def reset_image_of_variant(spree_variant, new_image)
        spree_variant.images.destroy_all
        spree_variant.images << new_image
        spree_variant.save
      end
    end

    after do
      cleanup_shopify_product_from_variant!(subject)
    end
  end
end
