require 'spec_helper'
require 'active_merchant/billing/gateways/shopify'

module ActiveMerchant::Billing
  RSpec.describe ShopifyGateway do
    let(:api_key) { 'api_key' }
    let(:password) { 'password' }
    let(:shop_name) { 'shop_name' }
    let(:transaction_id) { '0xDEADBEEF' }
    let(:pos_refund) { double('refund', errors: []) }

    describe '#refund' do
      let(:refund_amount) { 100 }
      let(:refunder_instance) { double('refunder_instance', perform: pos_refund) }
      let(:refunder) { double('refunder', new: refunder_instance) }

      subject { described_class.new(api_key: api_key, password: password, shop_name: shop_name, refunder: refunder) }

      it 'performs a refund' do
        expect(refunder_instance).to receive(:perform).once
        refund!
      end

      it 'returns an ActiveMerchant response' do
        result = refund!
        expect(result).to be_a(ActiveMerchant::Billing::Response)
      end

      context 'when refund was successful' do
        it 'returns an ActiveMerchant successful response' do
          result = refund!
          expect(result).to be_success
        end
      end

      context 'when refund was not successful' do
        let(:pos_refund) { double('refund', errors: refund_errors) }
        let(:refund_errors) { double('errors', messages: ['I am ERROR']) }

        before do
          allow(refunder_instance).to receive(:perform).and_return(pos_refund)
        end

        it 'returns an ActiveMerchant unsuccessful response' do
          result = refund!
          expect(result).not_to be_success
        end
      end

      private

      def refund!
        subject.refund(refund_amount, transaction_id, { order_id: transaction_id })
      end
    end

    describe '#void' do
      let(:refund_amount) { 100 }
      let(:voider_instance) { double('voider_instance', perform: pos_refund) }
      let(:voider) { double('voider', new: voider_instance) }

      subject { described_class.new(api_key: api_key, password: password, shop_name: shop_name, voider: voider) }

      it 'performs a refund' do
        expect(voider_instance).to receive(:perform).once
        void!
      end

      it 'returns an ActiveMerchant response' do
        result = void!
        expect(result).to be_a(ActiveMerchant::Billing::Response)
      end

      context 'when refund was successful' do
        it 'returns an ActiveMerchant successful response' do
          result = void!
          expect(result).to be_success
        end
      end

      context 'when refund was not successful' do
        let(:pos_refund) { double('refund', errors: refund_errors) }
        let(:refund_errors) { double('errors', messages: ['I am ERROR']) }

        before do
          allow(voider_instance).to receive(:perform).and_return(pos_refund)
        end

        it 'returns an ActiveMerchant unsuccessful response' do
          result = void!
          expect(result).not_to be_success
        end
      end

      private

      def void!
        subject.void(transaction_id, { order_id: transaction_id })
      end
    end
  end
end
