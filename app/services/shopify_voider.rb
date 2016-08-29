class ShopifyVoider
  def initialize(transaction_id, order_id)
    @order_id = order_id
    @transaction = ShopifyAPI::Transaction.find(transaction_id, params: { order_id: order_id })
  end

  def perform
    raise ActiveMerchant::Billing::ShopifyGateway::TransactionNotFoundError if transaction.nil?

    options = { order_id: order_id, reason: 'Payment voided' }
    full_amount_to_cents = BigDecimal.new(transaction.amount) * 100
    refunder = ShopifyRefunder.new(full_amount_to_cents, transaction.id, options)
    refunder.perform
  end

  private

  attr_reader :transaction, :order_id
end
