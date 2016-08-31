require 'spec_helper'
require 'active_merchant/billing/gateways/shopify'

module ActiveMerchant::Billing
  RSpec.describe ShopifyGateway do
    let(:api_key) { 'api_key' }
    let(:password) { 'password' }
    let(:shop_name) { 'shop_name' }

    let(:gateway) do
      described_class.new(api_key: api_key,
                          password: password,
                          shop_name: shop_name)
    end

    around(:each) do |example|
      begin
        previously = ShopifyAPI::Base.site
        example.run
      ensure
        ShopifyAPI::Base.site = previously
      end
    end

    describe "#void" do
      let(:transaction_id) { '123' }
      let(:transaction_amount) { 1 }
      let(:transaction) { double(:transaction, amount: transaction_amount, id: transaction_id) }

      let(:refunder) { double(:refunder, perform: true) }

      before do
        allow(ShopifyAPI::Transaction).to receive(:find).and_return(transaction)
        allow(ShopifyRefunder).to receive(:new).and_return(refunder)
      end

      it "performs a refund" do
        expect(refunder).to receive(:perform).once

        gateway.void(transaction_id, { order_id: transaction_id })
      end

      it 'returns an ActiveMerchant response' do
        result = subject.perform
        expect(result).to be_a(ActiveMerchant::Billing::Response)
      end

      context 'when refund was successful' do
        let(:pos_refund) { double('refund') }

        before do
          allow(refunder).to receive(:perform).and_return(pos_refund)
        end

        it 'returns an ActiveMerchant successful response' do
          result = subject.perform
          expect(result).to be_success
        end
      end

      context 'when refund was not successful' do
        let(:pos_refund) { double('refund', errors: errors) }
        let(:errors) { double('errors', messages: ['I am ERROR']) }

        before do
          allow(refunder).to receive(:perform).and_return(pos_refund)
        end

        it 'returns an ActiveMerchant unsuccessful response' do
          result = subject.perform
          expect(result).not_to be_success
        end
      end

      context "when the transaction can't be found" do
        let(:transaction) { nil }

        it "raises an exception" do
          cause = ->{ gateway.void(transaction_id, { order_id: transaction_id }) }

          expect(&cause).to raise_error Shopify::TransactionNotFoundError
        end
      end
    end

    describe "#refund" do
      let(:refund_amount) { 100 }
      let(:refund_errors) { [] }
      let(:refund_reason) { 'reason' }
      let(:transaction_id) { '123' }
      let(:transaction_amount) { 1 }

      let(:refund) { double(:refund, errors: refund_errors) }
      let(:transaction) { double(:transaction, amount: transaction_amount, id: transaction_id) }

      before do
        allow(ShopifyAPI::Transaction).to receive(:find).and_return(transaction)
        allow(ShopifyAPI::Refund).to receive(:create).and_return(refund)
      end

      it "refunds the customer successfully" do
        cause = ->{ gateway.refund(refund_amount, transaction_id, { order_id: transaction_id, reason: refund_reason }) }

        expect(cause.call).to be_success
      end

      context "when the transaction can't be found" do
        let(:refund_amount) { 100 }
        let(:transaction) { nil }

        it "raises an exception" do
          cause = ->{ gateway.refund(refund_amount, transaction_id, { order_id: transaction_id, reason: refund_reason }) }

          expect(&cause).to raise_error Shopify::TransactionNotFoundError
        end
      end

      context "when the amount to be credited exceeds the original transaction" do
        let(:refund_amount) { 10_000 }

        it "raises an exception" do
          cause = ->{ gateway.refund(refund_amount, transaction_id, { order_id: transaction_id, reason: refund_reason }) }

          expect(&cause).to raise_error Shopify::CreditedAmountBiggerThanTransaction
        end
      end

      context "when a validation error is encountered" do
        let(:refund_errors) { double(:errors, messages: { error: 'error1' }) }

        it "fails to perform the refund" do
          cause = ->{ gateway.refund(refund_amount, transaction_id, { order_id: transaction_id, reason: refund_reason }) }

          expect(cause.call).to_not be_success
        end
      end

      context 'when refund was successful' do
        let(:pos_refund) { double('refund') }

        before do
          allow(refunder).to receive(:perform).and_return(pos_refund)
        end

        it 'returns an ActiveMerchant successful response' do
          result = subject.perform
          expect(result).to be_success
        end
      end

      context 'when refund was not successful' do
        let(:pos_refund) { double('refund', errors: errors) }
        let(:errors) { double('errors', messages: ['I am ERROR']) }

        before do
          allow(refunder).to receive(:perform).and_return(pos_refund)
        end

        it 'returns an ActiveMerchant unsuccessful response' do
          result = subject.perform
          expect(result).not_to be_success
        end
      end
    end
  end
end
