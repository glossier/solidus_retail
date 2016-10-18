RSpec.shared_context 'ignore_shopify_hook_authentication' do
  before :each do
    allow_any_instance_of(Spree::Retail::Shopify::HooksController).to receive(:verify_request_authenticity).and_return(true)
  end
end
