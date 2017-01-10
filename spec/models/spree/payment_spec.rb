require 'spec_helper'

module Spree
  RSpec.describe Payment do
    let(:order) { create :order, pos_order_id: '8675309' }
    subject(:payment) { build_stubbed(:payment, order: order) }

    it 'knows its retail order ID' do
      expect(payment.pos_order_id).to eq '8675309'
    end
  end
end
