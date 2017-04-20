RSpec.shared_context 'shopify_helpers' do
  def find_shopify_product(spree_product)
    spree_product.reload
    ShopifyAPI::Product.find(spree_product.pos_product_id)
  end

  def find_shopify_variant(spree_variant)
    spree_variant.reload
    ShopifyAPI::Variant.find(spree_variant.pos_variant_id)
  end

  def find_shopify_user(spree_user)
    spree_user.reload
    ShopifyAPI::Customer.find(spree_user.pos_user_id)
  end

  # This will auto-destroy the variants, due to the shopify associations.
  def cleanup_shopify_product_from_spree!(spree_product)
    spree_product.reload
    find_shopify_product(spree_product).destroy
  end

  def cleanup_shopify_user_from_spree!(spree_user)
    spree_user.reload
    find_shopify_user(spree_user).destroy
  end

  def cleanup_shopify_variant_from_spree!(spree_variant)
    spree_variant.reload
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
