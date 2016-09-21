require 'spec_helper'

module Spree
  RSpec.describe Order do
    subject(:order) { build_stubbed(:order, pos_order_id: '8675309') }

    it 'knows its retail order ID' do
      expect(order.pos_order_id).to eq '8675309'
    end
  end
end
