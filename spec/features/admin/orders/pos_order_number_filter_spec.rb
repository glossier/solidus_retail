require 'spec_helper'

describe "Orders Listing", type: :feature, js: true do
  stub_authorization!

  before(:each) do
    allow_any_instance_of(Spree::OrderInventory).to receive(:add_to_shipment)
    @order1 = create(:order_with_line_items, created_at: 1.day.from_now, completed_at: 1.day.from_now, number: "R100")
    @order2 = create(:order, created_at: 1.day.ago, completed_at: 1.day.ago, number: "R200", pos_order_number: "POS200")
    visit spree.admin_orders_path
  end

  context "filter orders" do
    it "should be able to filter by POS order number" do
      fill_in "q_pos_order_number_cont", with: "POS200"
      click_on "Filter Results"
      within_row(1) { expect(page).to have_content("R200") }
      within("table#listing_orders") { expect(page).not_to have_content("R100") }
    end
  end
end
