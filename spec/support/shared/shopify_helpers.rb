RSpec.shared_context 'shopify_helpers' do
  def find_shopify_product(spree_product)
    ShopifyAPI::Product.find(spree_product.pos_product_id)
  end

  def find_shopify_variant(spree_variant)
    ShopifyAPI::Variant.find(spree_variant.pos_variant_id)
  end

  # This will auto-destroy the variants, due to the shopify associations.
  def cleanup_shopify_product_from_spree!(spree_product)
    find_shopify_product(spree_product).destroy
  end

  def cleanup_shopify_variant_from_spree!(spree_variant)
    find_shopify_variant(spree_variant).destroy
  end

  def cleanup_shopify_product!(shopify_product)
    shopify_product.destroy
  end

  def cleanup_shopify_variant!(shopify_variant)
    shopify_variant.destroy
  end

  def cleanup_shopify_product!(product)
    product.destroy
  end
end
