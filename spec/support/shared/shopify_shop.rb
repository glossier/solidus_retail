RSpec.shared_context 'shopify_shop' do
  let(:refund_amount) { 100 }
  let(:shopify_payment_method) do
    gateway = Spree::Gateway::ShopifyGateway.new
    gateway.set_preference(:api_key, ENV.fetch('SHOPIFY_API_KEY'))
    gateway.set_preference(:password, ENV.fetch('SHOPIFY_PASSWORD'))
    gateway.set_preference(:shop_name, ENV.fetch('SHOPIFY_SHOP_NAME'))
    gateway
  end

  def mock_request(endpoint, extension)
    url = "https://this-is-my-test-shop.myshopify.com/admin/#{endpoint}#{extension}"
    example = File.open("#{File.dirname(__FILE__)}/../data/#{endpoint}.#{extension}")
    body = JSON.parse(example.read)
    stub_request(:get, url)
      .with(body: body,
            headers: { 'Content-Type' => "text/#{extension}",
                       'Content-Length' => 1 })
  end
end
