require 'spec_helper'

require_relative '../../lib/active_merchant/billing/gateways/shopify.rb'

describe ShopifyVoider do
  let(:transaction_id) { '0xDEADBEEF' }
  let(:order_id) { 'order_id' }
  let(:transaction_amount) { 1 }
  let(:transaction) { double(:transaction, amount: transaction_amount, id: transaction_id) }
  let(:refunder_instance) { double('refunder_instance', perform: true) }

  before do
    allow(ShopifyAPI::Transaction).to receive(:find).and_return(transaction)
  end

  subject { described_class.new(transaction_id, order_id) }

  context '.initialize' do
    it 'successfully does it\'s thing' do
      expect(subject).to be_truthy
    end
  end

  context '.perform' do
    before do
      allow(ShopifyRefunder).to receive(:new).and_return(refunder_instance)
    end

    context 'when the shopify transaction is not found' do
      before do
        allow(ShopifyAPI::Transaction).to receive(:find).and_return(nil)
      end

      it 'throws an error' do
        cause = ->{ subject.perform }
        expect(&cause).to raise_error(ActiveMerchant::Billing::ShopifyGateway::TransactionNotFoundError)
      end
    end

    it 'calls the shopify refunder' do
      expect(refunder_instance).to receive(:perform)
      subject.perform
    end
  end
end
