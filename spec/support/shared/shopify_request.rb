RSpec.shared_context 'shopify_request' do
  require 'shopify_api'

  before :all do
    ActiveResource::Base.format = :json
    ShopifyAPI.constants.each do |const|
      begin
        const = "ShopifyAPI::#{const}".constantize
        const.format = :json if const.respond_to?(:format=)
      rescue NameError
      end
    end

    ShopifyAPI::Base.clear_session
    ShopifyAPI::Base.site = "https://this-is-my-test-shop.myshopify.com/admin"
    ShopifyAPI::Base.password = nil
    ShopifyAPI::Base.user = nil
  end

  def mock_request(endpoint, extension)
    file = endpoint.split('/')[0]
    url = "#{ShopifyAPI::Base.site}/#{endpoint}.#{extension}"
    json = File.open("#{File.dirname(__FILE__)}/../data/#{file}.#{extension}")
    stub_request(:get, url)
      .with(headers: { 'Accept' => "application/#{extension}",
                       'Accept-Encoding' => 'gzip;q=1.0,deflate;q=0.6,identity;q=0.3',
                       'User-Agent' => 'ShopifyAPI/4.3.2 ActiveResource/4.1.0 Ruby/2.3.1' })
      .to_return(status: 200, body: json.read, headers: {})
  end
end
