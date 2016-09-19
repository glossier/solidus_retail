require 'spec_helper'

module Spree
  module Retail
    module Shopify
      RSpec.describe CanIssueRefundPolicy do
        describe 'allowed?' do
          let(:amount_to_credit) { 100 }

          subject(:policy) do
            described_class.new(transaction: transaction,
                                amount_to_credit: amount_to_credit)
          end

          context 'when issuing a full refund of the transaction' do
            let(:transaction) { double(:transaction, amount: 2) }
            let(:amount_to_credit) { 200 }

            it { is_expected.to be_allowed }
          end

          context 'when issuing a partial refund of the transaction' do
            let(:transaction) { double(:transaction, amount: 2) }
            let(:amount_to_credit) { 100 }

            it { is_expected.to be_allowed }
          end

          context 'when the shopify transaction is not found' do
            let(:transaction) { nil }

            it 'throws an error' do
              cause = ->{ policy.allowed? }

              expect(&cause).to raise_error(Spree::Retail::Shopify::TransactionNotFoundError)
            end
          end

          context 'with a credited amount bigger than the transaction' do
            let(:transaction) { double(:transaction, amount: 1) }
            let(:amount_to_credit) { 200 }

            it 'throws an error' do
              cause = ->{ policy.allowed? }

              expect(&cause).to raise_error(Spree::Retail::Shopify::CreditedAmountBiggerThanTransaction)
            end
          end
        end
      end
    end
  end
end
