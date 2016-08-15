require 'spec_helper'

describe "Shopify webhook orders" do
  before do
    allow_any_instance_of(Spree::ShopifyHookController).to receive(:verify_webhook).and_return(true)
  end

  context '#create' do
    let(:request_body) { ShopifyRequest.create_order }

    it 'returns HTTP 200 status code' do
      call_create_refund_hook!
      binding.pry
      expect(response).to have_http_status(200)
    end

    def call_create_refund_hook!
      post '/shopify_hook/order', request_body, {}
    end
  end
end
