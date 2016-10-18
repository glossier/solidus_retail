require 'spec_helper'

module Spree::Retail::Shopify
  RSpec.describe CustomerImporter do
    include_context 'shopify_request'

    let!(:customer_response_mock) { mock_request('customers', 'customers/207119551', 'json') }
    let(:shopify_customer) { ShopifyAPI::Customer.find('207119551') }

    describe 'when the customer is not existing in spree' do
      it 'creates a spree user' do
        expect{ import_user!(shopify_customer) }.to change(Spree.user_class, :count).by 1
      end

      describe 'the spree user contains' do
        before do
          import_user!(shopify_customer)
        end

        it 'the shopify email address' do
          expect(last_user.email).to eql shopify_customer.email
        end
      end
    end

    private

    def import_user!(shopify_customer)
      described_class.new(customer: shopify_customer).perform
    end

    def last_user
      Spree.user_class.last
    end
  end
end
