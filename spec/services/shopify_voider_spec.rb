require 'spec_helper'

require_relative '../../lib/active_merchant/billing/gateways/shopify.rb'

describe Spree::Retail::ShopifyVoider do
  let(:transaction_id) { '0xDEADBEEF' }
  let(:order_id) { 'order_id' }
  let(:transaction_amount) { 1 }
  let(:transaction_instance) { double('transaction', amount: transaction_amount, id: transaction_id) }
  let(:transaction_interface) { double('transaction_interface', find: transaction_instance) }
  let(:refunder_instance) { double('refunder_instance', perform: true) }
  let(:refunder_class) { double('refunder_class', new: refunder_instance) }

  subject { described_class.new(transaction_id, order_id, transaction_interface, refunder_class) }

  context '.initialize' do
    it "successfully does it's thing" do
      expect(subject).to be_truthy
    end
  end

  context '.perform' do
    context 'when the shopify transaction is not found' do
      before do
        allow(transaction_interface).to receive(:find).and_return(nil)
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
