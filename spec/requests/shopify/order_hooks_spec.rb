require 'spec_helper'

describe 'Shopify sends a webhook event to Solidus', :vcr do
  include_context 'shopify_request'

  before do
    allow_any_instance_of(Spree::Retail::Shopify::HooksController).to receive(:verify_webhook).and_return(true)
  end

  context '#create' do
    let!(:request_body) { read_file_from_endpoint('orders/450789469', 'json') }

    it 'returns HTTP 200 status code' do
      call_create_refund_hook!
      expect(response).to have_http_status(200)
    end

    def call_create_refund_hook!
      post '/spree/retail/shopify/hooks/order', request_body, {}
    end
  end
end
