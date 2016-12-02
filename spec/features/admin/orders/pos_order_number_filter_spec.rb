require 'spec_helper'

describe "Orders Listing", type: :feature, js: true do
  stub_authorization!

  before(:each) do
    allow_any_instance_of(Spree::OrderInventory).to receive(:add_to_shipment)
    @order1 = create(:order_with_line_items, created_at: 1.day.from_now, completed_at: 1.day.from_now, number: "R100")
    @order2 = create(:order, created_at: 1.day.ago, completed_at: 1.day.ago, number: "R200")
    visit spree.admin_orders_path
  end

  context "filter orders" do
    it "should see the pos order number field" do
      save_and_open_screenshot
    end
  end
end
