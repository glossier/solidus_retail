require 'spec_helper'
require 'active_merchant/billing/gateways/shopify'

module ActiveMerchant::Billing
  RSpec.describe ShopifyGateway do
    # Arguments
    let(:api_key) { 'api_key' }
    let(:password) { 'password' }
    let(:shop_name) { 'shop_name' }

    # Injected dependencies
    let(:refunder_factory) { double(:refunder_factory, new: refunder) }
    let(:refunder) { double(:refunder, perform: pos_refund) }
    let(:transaction_repository) { double(:transaction_repository, find: transaction) }
    let(:transaction) { double(:transaction, id: transaction_id, amount: 100) }

    let(:gateway) do
      described_class.new(api_key: api_key,
                          password: password,
                          shop_name: shop_name,
                          refunder: refunder_factory,
                          transaction_repository: transaction_repository)
    end

    let(:pos_refund) { double('refund', errors: pos_refund_errors) }
    let(:pos_refund_errors) { [] }

    describe '#refund' do
      let(:order_id) { "0xCAFED00D" }
      let(:refund_amount) { 200 }
      let(:transaction_id) { '0xDEADBEEF' }

      subject(:refund!) do
        gateway.refund(refund_amount, transaction_id, { order_id: order_id })
      end

      before do
        allow(refunder).to receive(:perform).and_return(pos_refund)
      end

      it 'performs a refund' do
        expect(refunder_factory).to receive(:new).with(credited_money: 200,
                                                       transaction_id: '0xDEADBEEF',
                                                       order_id: '0xCAFED00D')
        expect(refunder).to receive(:perform).once

        refund!
      end

      context 'when refund was successful' do
        it 'returns an ActiveMerchant successful response' do
          result = refund!

          expect(result).to be_success
        end
      end

      context 'when refund was not successful' do
        let(:pos_refund_errors) { double('errors', messages: ['I am ERROR']) }

        it 'returns an ActiveMerchant unsuccessful response' do
          result = refund!

          expect(result).not_to be_success
        end
      end
    end

    describe '#void' do
      let(:transaction_id) { "0xDEADBEEF" }
      let(:order_id) { "0xCAFED00D" }

      subject(:void!) do
        gateway.void(transaction_id, { order_id: order_id })
      end

      it 'refunds the transaction' do
        expect(refunder_factory).to receive(:new).with(credited_money: 100,
                                                       transaction_id: '0xDEADBEEF',
                                                       order_id: '0xCAFED00D')
        expect(refunder).to receive(:perform)

        void!
      end

      context 'when refund was successful' do
        it 'returns an ActiveMerchant successful response' do
          result = void!

          expect(result).to be_success
        end
      end

      context 'when refund was not successful' do
        let(:pos_refund_errors) { double(:errors, messages: ['I am ERROR']) }

        it 'returns an ActiveMerchant unsuccessful response' do
          result = void!

          expect(result).not_to be_success
        end
      end
    end
  end
end
