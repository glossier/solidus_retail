require 'spec_helper'

describe ShopifyRefunder do
  let(:transaction_id) { '0xDEADBEEF' }
  let(:options) { { reason: 'Actual reason', order_id: transaction_id } }
  let(:transaction) { double(:transaction, amount: transaction_amount, id: transaction_id) }

  context '.initialize' do
    let(:transaction_amount) { 1 }
    let(:credited_money) { 1 }

    before do
      allow(ShopifyAPI::Transaction).to receive(:find).and_return(transaction)
    end

    subject { described_class.new(credited_money, transaction_id, options) }

    it 'successfully does it\'s thing' do
      expect(subject).to be_truthy
    end
  end

  context '.perform' do
    context 'when the shopify transaction is not found' do
      it 'throws an error' do
      end
    end

    context 'with a full refund' do
      let(:transaction_amount) { 1 }
      let(:credited_money) { 1 }

      subject { described_class.new(credited_money, transaction_id, options) }

      it 'performs a refund on shopify' do
      end
    end

    context 'with a partial refund' do
      it 'performs a refund on shopify' do
      end
    end

    context 'with a credited amount bigger than the transaction' do
      it 'throws an error' do
      end
    end

    context 'when the refunds contains an error' do
      it 'returns a response with an error' do
      end
    end
  end
end
