require 'spec_helper'

describe 'Export a Spree user', :vcr do
  include_context 'shopify_exporter_helpers'
  include_context 'shopify_helpers'

  let(:spree_user) { create(:user) }

  after do
    cleanup_shopify_user_from_spree!(spree_user)
  end

  it 'creates a user' do
    shopify_user = export_user_and_variants!(spree_user)
    expect(shopify_user.persisted?).to eql(true)
  end
end
