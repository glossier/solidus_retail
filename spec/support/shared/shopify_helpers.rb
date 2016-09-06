RSpec.shared_context 'shopify_helpers' do
  def cleanup_shopify_product_from_variant!(variant)
    product = ShopifyAPI::Product.find(variant.product_id)
    product.destroy
  end

  def find_shopify_product(spree_product)
    ShopifyAPI::Product.find(spree_product.pos_product_id)
  end

  def find_shopify_variant(spree_variant)
    ShopifyAPI::Variant.find(spree_variant.pos_variant_id)
  end

  def find_shopify_image(shopify_variant)
    ShopifyAPI::Image.find(shopify_variant.image_id, params: { product_id: shopify_variant.product_id })
  end

  def cleanup_shopify_product!(product)
    product.destroy
  end
end
