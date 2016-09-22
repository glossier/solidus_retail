RSpec.shared_context 'shopify_exporter_helpers' do
  def export_product_and_variants!(spree_product)
    exporter = Shopify::ProductExporter.new(spree_product: spree_product)
    shopify_product = exporter.save_product_on_shopify

    shopify_product
  end

  def export_bundle!(spree_product)
    exporter = Shopify::BundledProductExporter.new(spree_product: spree_product)
    shopify_product = exporter.save_product_on_shopify
    spree_product.reload

    shopify_product
  end

  def update_product!(spree_product)
    updater = Shopify::ProductUpdater.new(spree_product_id: spree_product.id)
    shopify_product = updater.save_product_on_shopify
    spree_product.reload

    shopify_product
  end

  def update_variant!(spree_variant)
    updater = Shopify::VariantUpdater.new(spree_variant_id: spree_variant.id)
    shopify_variant = updater.perform
    spree_variant.reload

    shopify_variant
  end
end
