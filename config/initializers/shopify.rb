class ShopifyConfig
  def shop_url
    "https://#{shopify_api_key}:#{shopify_password}@#{shopify_shared_secret}"
  end

  private

  def shopify_api_key
    ENV.fetch('SHOPIFY_API_KEY')
  end

  def shopify_password
    ENV.fetch('SHOPIFY_PASSWORD')
  end

  def shopify_shared_secret
    ENV.fetch('SHOPIFY_SHARED_SECRET')
  end
end

ShopifyAPI::Base.site = ShopifyConfig.new.shop_url
