require 'spec_helper'

describe 'Refund a Shopify order on Glossier', :vcr do
  include_context 'shopify_shop'
  let(:refund_reason) { create(:refund_reason) }

  context 'that is partially fulfilled' do
    let(:pos_order) { create_fulfilled_paid_shopify_order }
    let(:order) { create(:order, pos_order_id: pos_order.id) }
    let(:transaction) { ShopifyAPI::Order.find(pos_order.id).transactions.first }
    let(:payment) do
      create(:payment, order: order,
             response_code: transaction.id,
             amount: refund_amount,
             payment_method: shopify_payment_method)
    end

    let(:refund) do
      refund = Spree::Refund.new
      refund.payment = payment
      refund.reason = refund_reason
      refund.amount = refund_amount

      refund
    end

    before do
      refund.save
    end

    it 'is refunding the order on Shopify' do
      refunds = ShopifyAPI::Order.find(pos_order.id).refunds
      expect(refunds.count).to eql(1)
    end

    after do
      pos_order.destroy
    end
  end
end
