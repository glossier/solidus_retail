RSpec.shared_context 'create_default_shop' do
  let!(:store) { create :store }
  let!(:shipping_method) { create :shipping_method, admin_name: 'POS' }
  let!(:stock_location) { create :stock_location, admin_name: 'POPUP' }
  let!(:payment_method) { create :retail_payment_method }
  let!(:refund_reason) { create :refund_reason }
  let!(:shipping_rate) { create :shipping_rate }
  let!(:return_reason) { create :return_reason }
  let!(:source) { create :credit_card, name: 'POS' }
end
