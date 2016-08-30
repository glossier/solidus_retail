require 'spec_helper'

require_relative '../../lib/active_merchant/billing/gateways/shopify.rb'

describe ShopifyRefunder do
  let(:transaction_id) { '0xDEADBEEF' }
  let(:options) { { reason: 'Actual reason', order_id: transaction_id } }
  let(:transaction_amount) { 1 }
  let(:credited_money_in_cents) { 100 }
  let(:transaction) { double(:transaction, amount: transaction_amount, id: transaction_id) }

  before do
    allow(ShopifyAPI::Transaction).to receive(:find).and_return(transaction)
  end

  context '.initialize' do
    subject { described_class.new(credited_money_in_cents, transaction_id, options) }

    it 'successfully does it\'s thing' do
      expect(subject).to be_truthy
    end
  end

  context '.perform' do
    let(:pos_refund) { double('refund', errors: []) }

    before do
      allow(ShopifyAPI::Refund).to receive(:create).and_return(pos_refund)
    end

    context 'when the shopify transaction is not found' do
      before do
        allow(ShopifyAPI::Transaction).to receive(:find).and_return(nil)
      end

      subject { described_class.new(credited_money_in_cents, transaction_id, options) }

      it 'throws an error' do
        cause = ->{ subject.perform }
        expect(&cause).to raise_error(ActiveMerchant::Billing::ShopifyGateway::TransactionNotFoundError)
      end
    end

    context 'with a full refund' do
      subject { described_class.new(credited_money_in_cents, transaction_id, options) }

      it 'performs a refund on shopify' do
        expect(ShopifyAPI::Refund).to receive(:create)
        subject.perform
      end

      it 'returns an ActiveMerchant response' do
        result = subject.perform
        expect(result).to be_a(ActiveMerchant::Billing::Response)
      end

      it 'returns an ActiveMerchant succesfull response' do
        result = subject.perform
        expect(result.success?).to be_truthy
      end
    end

    context 'with a partial refund' do
      let(:transaction_amount) { 2 }
      let(:credited_money_in_cents) { 100 }

      subject { described_class.new(credited_money_in_cents, transaction_id, options) }

      it 'performs a refund on shopify' do
        expect(ShopifyAPI::Refund).to receive(:create)
        subject.perform
      end

      it 'returns an ActiveMerchant response' do
        result = subject.perform
        expect(result).to be_a(ActiveMerchant::Billing::Response)
      end

      it 'returns an ActiveMerchant succesfull response' do
        result = subject.perform
        expect(result.success?).to be_truthy
      end
    end

    context 'with a credited amount bigger than the transaction' do
      let(:transaction_amount) { 1 }
      let(:credited_money_in_cents) { 200 }

      subject { described_class.new(credited_money_in_cents, transaction_id, options) }

      it 'throws an error' do
        cause = ->{ subject.perform }
        expect(&cause).to raise_error(ActiveMerchant::Billing::ShopifyGateway::CreditedAmountBiggerThanTransaction)
      end
    end

    context 'when the refunds contains an error' do
      let(:pos_refund) { double('refund', errors: errors) }
      let(:errors) { double('errors', messages: ['I am ERROR']) }

      subject { described_class.new(credited_money_in_cents, transaction_id, options) }

      it 'returns a response with an error' do
        result = subject.perform
        expect(result.success?).to be_falsey
      end
    end
  end
end
