RSpec.shared_context 'shopify_exporter_helpers' do
  def export_product!(spree_product)
    exporter = Shopify::ProductExporter.new(spree_product_id: spree_product.id)
    exporter.perform
  end
end
