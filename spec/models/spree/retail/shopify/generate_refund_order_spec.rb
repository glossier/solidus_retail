require 'spec_helper'

Spree.describe Spree::Retail::Shopify::GenerateRefundOrder, type: :model do
  include_context 'shopify_request'

  let!(:store) { create :store }
  let!(:shipping_method) { create :shipping_method, admin_name: 'POS' }
  let!(:stock_location) { create :stock_location, admin_name: 'POPUP' }
  let!(:payment_method) { create :retail_payment_method }
  let!(:refund_reason) { create :refund_reason }
  let!(:return_reason) { create :return_reason }
  let!(:reimbursement_type) { create :reimbursement_type }
  let!(:source) { create :credit_card, name: 'POS' }
  let!(:order) { create(:completed_order_with_totals, pos_order_id: '3937615427') }

  let!(:refund_response_mock) { mock_request('refunds', 'orders/3937615427/refunds/149756227', 'json') }
  let(:refund_response) { ShopifyAPI::Refund.find('149756227', params: { order_id: '3937615427' }) }

  before do
    order.shipments.first.inventory_units.first.variant.update(pos_variant_id: 29637399811)
    allow_any_instance_of(Spree::Reimbursement).to receive(:perform!).and_return(true)
  end

  describe '#process' do
    subject { described_class.new(refund_response).process }

    it 'successfully creates a spree refund' do
      expect{ subject }.to change(Spree::Refund, :count).by 1
    end

    it 'successfully creates a spree reimbursement' do
      expect{ subject }.to change(Spree::Reimbursement, :count).by 1
    end

    it 'successfully creates a spree customer return' do
      expect{ subject }.to change(Spree::CustomerReturn, :count).by 1
    end
  end
end
