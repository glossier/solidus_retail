require 'spec_helper'

module Spree
  RSpec.describe Gateway::ShopifyGateway do
    let(:transaction_id) { '0xDEADBEEF' }
    let(:pos_order_id) { '0xBAADF00D' }
    let(:refund) { double('refund', pos_order_id: pos_order_id) }
    let(:refund_reason) { double('refund_reason', name: 'Product not working') }
    let(:gateway_options) { { originator: refund } }

    let(:provider_class) { ActiveMerchant::Billing::ShopifyGateway }
    let(:provider_instance) { double('provider', refund: true, void: true) }

    subject(:gateway) do
      described_class.create!(name: "Shopify")
    end

    before do
      gateway.preferences = { api_key: ENV['SHOPIFY_API_KEY'],
                              password: ENV['SHOPIFY_PASSWORD'],
                              shop_name: ENV['SHOPIFY_SHOP_NAME'] }

      allow(provider_class).to receive(:new).and_return(provider_instance)
    end

    describe "#payment_profiles_supported?" do
      it { is_expected.to_not be_payment_profiles_supported }
    end

    context '.void' do
      let(:payments) { double(:payments, find_by: payment) }
      let(:payment) { double(:payment, pos_order_id: pos_order_id) }

      before do
        allow(gateway).to receive(:payments).and_return(payments)
      end

      it 'calls the provider void method once' do
        expect(provider_instance).to receive(:void).with('0xDEADBEEF', order_id: '0xBAADF00D')

        void!
      end

      context "without a matching payment" do
        let(:payment) { nil }

        it 'raises an exception' do
          cause = -> { void! }

          expect(&cause).to raise_error(Gateway::ShopifyGateway::PaymentNotFoundError)
        end
      end

      private

      def void!
        gateway.void(transaction_id, gateway_options)
      end
    end

    context '.cancel' do
      it 'throws an error because it\'s not implemented' do
        expect { cancel! }.to raise_error(NotImplementedError)
      end

      private

      def cancel!
        gateway.cancel(transaction_id)
      end
    end

    context '.credit' do
      let(:amount_in_cents) { '100' }

      before do
        allow(refund).to receive(:reason).and_return(refund_reason)
      end

      it 'calls the provider refund method once' do
        expect(provider_instance).to receive(:refund).once
        refund!
      end

      private

      def refund!
        gateway.credit(amount_in_cents, transaction_id, originator: refund)
      end
    end
  end
end
