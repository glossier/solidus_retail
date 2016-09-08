RSpec.shared_context 'shopify_exporter_helpers' do
  def export_product!(spree_product)
    exporter = Shopify::ProductExporter.new(spree_product_id: spree_product.id)
    shopify_product = exporter.perform
    spree_product.reload

    shopify_product
  end

  def export_variant!(spree_variant)
    exporter = Shopify::VariantExporter.new(spree_variant_id: spree_variant.id)
    shopify_variant = exporter.perform
    spree_variant.reload

    shopify_variant
  end
end
