RSpec.shared_context 'shopify_request' do
  include_context 'shopify_mock'

  def create_shopify_order(order_id)
    @mocked_order = mock_request("order_#{order_id}", "orders/#{order_id}", 'json')
    @mocked_transactions = mock_request('transactions', "orders/#{order_id}/transactions", 'json')
    ShopifyAPI::Order.find(order_id)
  end

  def create_shopify_refund(order_id:, refund_id:)
    @mocked_refund = mock_request('refunds', "orders/#{order_id}/refunds/#{refund_id}", 'json')
    ShopifyAPI::Refund.find(refund_id, params: { order_id: order_id })
  end
end
