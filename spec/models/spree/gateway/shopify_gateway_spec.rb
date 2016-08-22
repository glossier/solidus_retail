require 'spec_helper'

describe Spree::Gateway::ShopifyGateway do
  let(:transaction_id) { '0xDEADBEEF' }
  let(:pos_order_id) { '0xBAADF00D' }
  let(:refund) { double('refund', pos_order_id: pos_order_id) }
  let(:refund_reason) { double('refund_reason', name: 'Product not working') }
  let(:gateway_options) { { originator: refund } }

  let(:provider_class) { ActiveMerchant::Billing::ShopifyGateway }
  let(:provider_instance) { double('provider', refund: true, void: true) }

  before do
    subject.preferences = { api_key: ENV['SHOPIFY_API_KEY'],
                            password: ENV['SHOPIFY_PASSWORD'],
                            shop_name: ENV['SHOPIFY_SHOP_NAME'] }
    allow(provider_class).to receive(:new).and_return(provider_instance)
  end

  context '.void' do
    it 'calls the provider void method once' do
      expect(provider_instance).to receive(:void).once
      void!
    end

    private

    def void!
      subject.void(transaction_id, gateway_options)
    end
  end

  context '.cancel' do
    it 'throws an error because it\'s not implemented' do
      expect { cancel! }.to raise_error(NotImplementedError)
    end

    private

    def cancel!
      subject.cancel(transaction_id)
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
      subject.credit(amount_in_cents, transaction_id, originator: refund)
    end
  end
end
