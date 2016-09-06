class ShopifyConfig
  def shop_url
    "https://#{shopify_api_key}:#{shopify_password}@#{shopify_shop_name}"
  end

  private

  def shopify_api_key
    ENV.fetch('SHOPIFY_API_KEY')
  end

  def shopify_password
    ENV.fetch('SHOPIFY_PASSWORD')
  end

  def shopify_shop_name
    ENV.fetch('SHOPIFY_SHOP_NAME')
  end
end

ShopifyAPI::Base.site = ShopifyConfig.new.shop_url
