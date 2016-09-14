require 'spec_helper'
require 'solidus_retail/order/generate_pos_order'

RSpec.describe SolidusRetail::Order::GeneratePosOrder, type: :model do
  include_context 'shopify_request'

  let(:order_response) { mock_request('orders/450789469', 'json') }
  subject { described_class.new(order_response) }

  it 'instantiates itself successfully' do
    expect(subject).to be_a SolidusRetail::Order::GeneratePosOrder
  end
end
