RSpec.shared_context 'shopify_exporter_helpers' do
  def export_product!(spree_product)
    exporter = Shopify::ProductExporter.new(spree_product_id: spree_product.id)
    shopify_product = exporter.perform
    spree_product.reload

    shopify_product
  end
end
