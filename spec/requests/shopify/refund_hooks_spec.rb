require 'spec_helper'

describe 'Shopify sends a refund webhook event to Solidus', :vcr do
  include_context 'shopify_request'

  let(:generator_instance) { double('instance', process: true) }
  let(:spree_refund) { double('spree_refund') }

  before do
    allow_any_instance_of(Spree::Retail::Shopify::HooksController).to receive(:verify_request_authenticity).and_return(true)
    allow(ShopifyAPI::Refund).to receive(:find).and_return(spree_refund)
    allow(Spree::Retail::Shopify::GenerateRefundOrder).to receive(:new).and_return(generator_instance)
  end

  context '#create' do
    let!(:request_body) { read_file('refunds', 'json') }

    it 'returns HTTP 200 status code' do
      call_create_refund_hook!
      expect(response).to have_http_status(200)
    end

    it 'calls the pos refund order generator' do
      expect(generator_instance).to receive(:process).and_return(true)
      call_create_refund_hook!
    end

    private

    def call_create_refund_hook!
      post '/retail/shopify/hooks/refund', request_body, {}
    end
  end
end
