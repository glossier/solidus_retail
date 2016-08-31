require 'spec_helper'

require_relative '../../lib/active_merchant/billing/gateways/shopify.rb'

describe Spree::Retail::ShopifyRefunder do
  let(:transaction_id) { '0xDEADBEEF' }
  let(:options) { { reason: 'Actual reason', order_id: transaction_id } }
  let(:transaction_amount) { 1 }
  let(:credited_money_in_cents) { 100 }
  let(:transaction_instance) { double('transaction_instance', amount: transaction_amount, id: transaction_id) }
  let(:transaction_interface) { double('transaction_interface', find: transaction_instance) }

  context '.initialize' do
    subject { described_class.new(credited_money_in_cents, transaction_id, options, transaction_interface) }

    it 'successfully does it\'s thing' do
      expect(subject).to be_truthy
    end
  end

  context '.perform' do
    let(:pos_refund) { double('refund', errors: []) }
    let(:refunder_interface) { double('refunder_interface', create: pos_refund) }

    subject { described_class.new(credited_money_in_cents, transaction_id, options, transaction_interface, refunder_interface) }

    context 'when the shopify transaction is not found' do
      before do
        allow(transaction_interface).to receive(:find).and_return(nil)
      end

      it 'throws an error' do
        cause = ->{ subject.perform }
        expect(&cause).to raise_error(ActiveMerchant::Billing::ShopifyGateway::TransactionNotFoundError)
      end
    end

    context 'with a full refund' do
      it 'performs a refund on shopify' do
        expect(refunder_interface).to receive(:create)
        subject.perform
      end

      it 'returns an ActiveMerchant response' do
        result = subject.perform
        expect(result).to be_a(ActiveMerchant::Billing::Response)
      end

      it 'returns an ActiveMerchant successful response' do
        result = subject.perform
        expect(result).to be_success
      end
    end

    context 'with a partial refund' do
      let(:transaction_amount) { 2 }
      let(:credited_money_in_cents) { 100 }

      subject { described_class.new(credited_money_in_cents, transaction_id, options, transaction_interface, refunder_interface) }

      it 'performs a refund on shopify' do
        expect(refunder_interface).to receive(:create)
        subject.perform
      end

      it 'returns an ActiveMerchant response' do
        result = subject.perform
        expect(result).to be_a(ActiveMerchant::Billing::Response)
      end

      it 'returns an ActiveMerchant successful response' do
        result = subject.perform
        expect(result).to be_success
      end
    end

    context 'with a credited amount bigger than the transaction' do
      let(:transaction_amount) { 1 }
      let(:credited_money_in_cents) { 200 }

      subject { described_class.new(credited_money_in_cents, transaction_id, options, transaction_interface, refunder_interface) }

      it 'throws an error' do
        cause = ->{ subject.perform }
        expect(&cause).to raise_error(ActiveMerchant::Billing::ShopifyGateway::CreditedAmountBiggerThanTransaction)
      end
    end

    context 'when the refunds contains an error' do
      let(:pos_refund) { double('refund', errors: errors) }
      let(:errors) { double('errors', messages: ['I am ERROR']) }

      it 'returns a response with an error' do
        result = subject.perform
        expect(result).not_to be_success
      end
    end
  end
end
