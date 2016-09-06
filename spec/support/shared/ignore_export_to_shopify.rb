RSpec.shared_context 'ignore_export_to_shopify' do
  before :each do
    allow(ExportProductToShopifyJob).to receive(:perform_later).and_return(true)
  end
end
