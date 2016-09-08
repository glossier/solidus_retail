require 'spec_helper'

describe 'Updates the Shopofy Variant quantity with the Spree Variant quantity' do
  before do
    allow_any_instance_of(Spree::Product).to receive(:export_to_shopify).and_return(true)
    WebMock.allow_net_connect!
  end

  after do
    WebMock.disable_net_connect!
  end

  context 'with product and variant saved' do
    let(:spree_product) { create(:product) }
    let!(:spree_variant) { create(:variant, product: spree_product) }

    subject { Shopify::StockExporter.new(spree_variant.id) }

    before do
      Shopify::ProductExporter.new(spree_product.id).perform
      spree_variant.reload
      spree_product.reload
    end

    it 'saves the variant new inventory quantity' do
      spree_variant.stock_items.first.set_count_on_hand(10)
      spree_variant.save
      spree_variant.reload

      result = subject.perform
      expect(result).to be_truthy
      expect(result.inventory_quantity).to eql(10)
    end

    after do
      product = ShopifyAPI::Product.find(spree_product.pos_product_id)
      product.destroy
    end
  end
end
