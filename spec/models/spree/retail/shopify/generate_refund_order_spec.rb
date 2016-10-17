require 'spec_helper'

Spree.describe Spree::Retail::Shopify::GenerateRefundOrder, type: :model do
  include_context 'shopify_request'

  let!(:store) { create :store }
  let!(:shipping_method) { create :shipping_method, admin_name: 'POS' }
  let!(:stock_location) { create :stock_location, admin_name: 'POPUP' }
  let!(:payment_method) { create :retail_payment_method }
  let!(:refund_reason) { create :refund_reason }
  let!(:shipping_rate) { create :shipping_rate }
  let!(:return_reason) { create :return_reason }
  let!(:source) { create :credit_card, name: 'POS' }
  let!(:variant) { create :variant, price: 12.00, pos_variant_id: '29637399811' }

  let!(:order_response_mock) { mock_request('orders', 'orders/450789469', 'json') }
  let(:order_response) { ShopifyAPI::Order.find('450789469') }
  let!(:refund_response_mock) { mock_request('refunds', 'orders/450789469/refunds/149756227', 'json') }
  let!(:transaction_response_mock) { mock_request('transactions', 'orders/450789469/transactions', 'json') }
  let(:refund_response) { ShopifyAPI::Refund.find('149756227', params: { order_id: '450789469' }) }

  before :each do
    allow(Spree::Variant).to receive(:find_by) { variant }
    allow_any_instance_of(Spree::Order).to receive(:ensure_available_shipping_rates) { true }
    allow(Spree::RefundReason).to receive(:return_processing_reason) { refund_reason }
    variant.stock_items.first.update_attribute(:count_on_hand, 1900)
  end

  let!(:order) { generate_pos_order!(order_response) }

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

    it 'sets the order state to returned' do
      subject
      expect(last_order).to be_returned
    end

    describe 'when order has already been returned' do
      subject { described_class.new(refund_response) }

      before do
        described_class.new(refund_response).process
      end

      it 'does not create a return authorization' do
        expect(subject).not_to receive(:create_return_authorization)
        subject.process
      end
    end
  end

  private

  def last_order
    Spree::Order.last
  end

  def generate_pos_order!(shopify_order)
    Spree::Retail::Shopify::GeneratePosOrder.new(shopify_order).process
  end
end
