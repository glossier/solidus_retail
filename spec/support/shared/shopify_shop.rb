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
    file = endpoint.split('/')[0]
    url = "https://this-is-my-test-shop.myshopify.com/admin/#{endpoint}.#{extension}"
    json = File.open("#{File.dirname(__FILE__)}/../data/#{file}.#{extension}")
    stub_request(:get, url)
      .with(headers: { 'Content-Type' => "text/#{extension}",
                       'Content-Length' => 1 })
      .to_return(status: 200, body: json.read)
  end
end
