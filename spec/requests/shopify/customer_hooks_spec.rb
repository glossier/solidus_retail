require 'spec_helper'

describe 'Shopify sends a customer webhook event to Solidus', :vcr do
  include_context 'shopify_request'

  let(:importer_instance) { double('instance', perform: true) }
  let(:shopify_customer) { double('shopify_customer') }

  before do
    # TODO: Put that into a context v
    allow_any_instance_of(Spree::Retail::Shopify::HooksController).to receive(:verify_request_authenticity).and_return(true)
    allow(ShopifyAPI::Customer).to receive(:find).and_return(shopify_customer)
    allow(Spree::Retail::Shopify::CustomerImporter).to receive(:new).and_return(importer_instance)
  end

  context '#create' do
    let!(:request_body) { read_file('customers', 'json') }

    it 'returns HTTP 200 status code' do
      call_create_customer_hook!
      expect(response).to have_http_status(200)
    end

    it 'calls the customer importer' do
      expect(importer_instance).to receive(:perform).and_return(true)
      call_create_customer_hook!
    end

    private

    def call_create_customer_hook!
      post '/retail/shopify/hooks/user', request_body, {}
    end
  end
end
