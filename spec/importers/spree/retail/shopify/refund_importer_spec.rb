require 'spec_helper'

module Spree::Retail::Shopify
  Spree.describe RefundImporter, type: :model do
    include_context 'create_default_shop'
    include_context 'shopify_request'

    let(:shopify_order) { create_shopify_order('450789469') }
    let(:shopify_refund) { create_shopify_refund(order_id: '450789469', refund_id: '149756227') }
    let!(:order) do
      variant = create(:variant, price: 12.00, pos_variant_id: '29637399811')
      variant.stock_items.first.update_attribute(:count_on_hand, 1900)
      allow(Spree::Variant).to receive(:find_by) { variant }
      allow(Spree::RefundReason).to receive(:return_processing_reason) { refund_reason }
      allow_any_instance_of(Spree::Order).to receive(:ensure_available_shipping_rates) { true }
      generate_pos_order(shopify_order)
    end

    let(:callback) { double(:callback, success_case: true, failure_case: false) }

    describe '#perform' do
      describe 'when it is a full refund' do
        subject { described_class.new(shopify_refund, callback: callback) }

        it 'successfully creates a spree refund' do
          expect{ subject.perform }.to change(Spree::Refund, :count).by 1
        end

        it 'successfully creates a spree reimbursement' do
          expect{ subject.perform }.to change(Spree::Reimbursement, :count).by 1
        end

        it 'successfully creates a spree customer return' do
          expect{ subject.perform }.to change(Spree::CustomerReturn, :count).by 1
        end

        it 'adds the correct amount of taxes to the order' do
          subject.perform
          expect(last_order.total).to eql(13.07)
        end

        it 'adds the adjustmennts containing the taxes to the line item' do
          subject.perform
          line_item = last_order.line_items.first

          expect(line_item.adjustments.count).to eql(2)
          expect(line_item.adjustments[0].label).to eql('NY State Tax')
          expect(line_item.adjustments[1].label).to eql('New York County Tax')
        end

        it 'sets the order state to returned' do
          subject.perform
          expect(last_order).to be_returned
        end

        it 'matches the Shopify refund total' do
          subject.perform
          last_order_refund_total = last_order.reimbursements.map(&:total).inject(:+)
          refund_transaction_total = shopify_refund.transactions.first.amount.to_f

          expect(last_order_refund_total).to eql(refund_transaction_total)
        end

        it 'goes through the success path' do
          expect(callback).to receive(:success_case).once
          subject.perform
        end
      end

      describe 'when order has already been returned' do
        subject { described_class.new(shopify_refund, callback: callback) }

        before do
          described_class.new(shopify_refund, callback: callback).perform
        end

        it 'does not create a refund' do
          expect{ subject.perform }.to change(Spree::Refund, :count).by 0
        end

        it 'does not create a reimbursement' do
          expect{ subject.perform }.to change(Spree::Reimbursement, :count).by 0
        end

        it 'does not create a customer return' do
          expect{ subject.perform }.to change(Spree::CustomerReturn, :count).by 0
        end

        it 'goes through the success path' do
          expect(callback).to receive(:success_case).once
          subject.perform
        end
      end
    end

    private

    def last_order
      Spree::Order.last
    end

    def generate_pos_order(shopify_order)
      Spree::Retail::Shopify::GeneratePosOrder.new(shopify_order).process
    end
  end
end
