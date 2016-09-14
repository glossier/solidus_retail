require 'spec_helper'
require 'solidus_retail/order/generate_pos_order'
require 'shopify_api'

RSpec.describe SolidusRetail::Order::GeneratePosOrder, type: :model do
  include_context 'shopify_shop'

  it 'instantiates itself successfully' do
  end
end
