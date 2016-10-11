require 'spec_helper'

describe 'Shopify sends an order webhook event to Solidus', :vcr do
  include_context 'shopify_request'

  let(:generator_instance) { double('instance', process: true) }
  let(:spree_order) { double('spree_order') }

  before do
    allow_any_instance_of(Spree::Retail::Shopify::HooksController).to receive(:verify_request_authenticity).and_return(true)
    allow(ShopifyAPI::Order).to receive(:find).and_return(spree_order)
    allow(Spree::Retail::Shopify::GeneratePosOrder).to receive(:new).and_return(generator_instance)
  end

  context '#create' do
    let!(:request_body) { read_file_from_endpoint('orders/450789469', 'json') }

    it 'returns HTTP 200 status code' do
      call_create_order_hook!
      expect(response).to have_http_status(200)
    end

    it 'calls the pos order generator' do
      expect(generator_instance).to receive(:process).and_return(true)
      call_create_order_hook!
    end

    private

    def call_create_order_hook!
      post '/retail/shopify/hooks/order', request_body, {}
    end
  end
end
