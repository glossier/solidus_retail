require 'spec_helper'

module Spree
  RSpec.describe Refund do
    let(:order) { create :order, pos_order_id: '8675309' }
    let(:payment) { create :payment, order: order }
    subject(:refund) { build_stubbed(:refund, payment: payment) }

    it 'knows its retail order ID' do
      expect(refund.pos_order_id).to eq '8675309'
    end
  end
end
