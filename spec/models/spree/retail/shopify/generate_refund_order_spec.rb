require 'spec_helper'

Spree.describe Spree::Retail::Shopify::GenerateRefundOrder, type: :model do
  include_context 'shopify_request'

  let!(:store) { create :store }
  let!(:shipping_method) { create :shipping_method, admin_name: 'POS' }
  let!(:stock_location) { create :stock_location, admin_name: 'POPUP' }
  let!(:payment_method) { create :retail_payment_method }
  let!(:refund_reason) { create :refund_reason }
  let!(:source) { create :credit_card, name: 'POS' }
  let(:variant) { create :variant }

  let!(:order)  { create :order, pos_order_id: '3937615427' }

  let!(:payment) do
    payment = order.payments.create(payment_method: payment_method)
    payment.update(amount: 13.07)
  end

  let!(:response_mock) { mock_request('refunds', 'orders/3937615427/refunds/149756227', 'json') }
  let(:refund_response) { ShopifyAPI::Refund.find('149756227', params: { order_id: '3937615427' }) }

  subject { described_class.new(refund_response) }

  describe '#process' do
    subject { described_class.new(refund_response).process }

    it 'successfully creates a solidus refund' do
      expect{ subject }.to change(Spree::Refund, :count).by 1
    end
  end
end
