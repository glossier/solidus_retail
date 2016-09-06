require 'spec_helper'

module Spree::Retail
  RSpec.describe ShopifyRefunder do
    # Parameters
    let(:credited_money_in_cents) { 100 }
    let(:order_id) { transaction_id }
    let(:refund_reason) { 'Actual reason' }
    let(:transaction_amount) { 1 }
    let(:transaction_id) { '0xDEADBEEF' }

    # Injected dependencies
    let(:can_issue_refund_policy_klass) { double(:can_issue_refund_policy_klass, new: can_issue_refund_policy) }
    let(:can_issue_refund_policy) { double(:can_issue_refund_policy) }
    let(:refunder_interface) { double(:refunder_interface, create: pos_refund) }
    let(:pos_refund) { double(:pos_refund) }
    let(:transaction_instance) { double(:transaction_instance, amount: transaction_amount, id: transaction_id) }
    let(:transaction_interface) { double(:transaction_interface, find: transaction_instance) }

    subject(:refunder) do
      described_class.new(credited_money: credited_money_in_cents,
                          transaction_id: transaction_id,
                          reason: refund_reason,
                          order_id: order_id,
                          transaction_interface: transaction_interface,
                          refunder_interface: refunder_interface,
                          can_issue_refund_policy_klass: can_issue_refund_policy_klass)
    end

    context '.initialize' do
      it 'successfully does its thing' do
        expect(refunder).to be_a described_class
      end
    end

    context '.perform' do
      context "when the refund can be issued" do
        before do
          allow(can_issue_refund_policy).to receive(:allowed?).and_return(true)
        end

        it 'performs a refund in shopify' do
          expect(refunder_interface).to receive(:create)

          refunder.perform
        end
      end

      context 'when the refund cannot be issued' do
        class MockError < RuntimeError; end

        let(:mock_error) { MockError.new }

        before do
          allow(can_issue_refund_policy).to receive(:allowed?).and_raise(mock_error)
        end

        it 'raises an error' do
          cause = ->{ refunder.perform }
          expect(&cause).to raise_error MockError
        end
      end
    end
  end
end
