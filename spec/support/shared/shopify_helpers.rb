RSpec.shared_context 'shopify_helpers' do
  def find_shopify_product(spree_product)
    ShopifyAPI::Product.find(spree_product.pos_product_id)
  end

  def cleanup_shopify_product!(product)
    product.destroy
  end
end
