require 'spec_helper'

module Spree::Retail
  RSpec.describe ShopifyRefunder do
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
      let(:pos_refund) { double('refund') }
      let(:refunder_interface) { double('refunder_interface', create: pos_refund) }

      subject { described_class.new(credited_money_in_cents, transaction_id, options, transaction_interface, refunder_interface) }

      context 'when the shopify transaction is not found' do
        before do
          allow(transaction_interface).to receive(:find).and_return(nil)
        end

        it 'throws an error' do
          cause = ->{ subject.perform }
          expect(&cause).to raise_error(Spree::Retail::Shopify::TransactionNotFoundError)
        end
      end

      context 'with a full refund' do
        it 'performs a refund on shopify' do
          expect(refunder_interface).to receive(:create)
          subject.perform
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
      end

      context 'with a credited amount bigger than the transaction' do
        let(:transaction_amount) { 1 }
        let(:credited_money_in_cents) { 200 }

        subject { described_class.new(credited_money_in_cents, transaction_id, options, transaction_interface, refunder_interface) }

        it 'throws an error' do
          cause = ->{ subject.perform }
          expect(&cause).to raise_error(Spree::Retail::Shopify::CreditedAmountBiggerThanTransaction)
        end
      end
    end
  end
end
