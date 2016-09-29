RSpec.shared_context 'shopify_exporter_helpers' do
  def export_product_and_variants!(spree_product)
    exporter = Spree::Retail::Shopify::ProductExporter.new(spree_product: spree_product)
    shopify_product = exporter.perform
    spree_product.reload
    spree_product.variants_including_master.map(&:reload)

    shopify_product
  end

  def export_bundle!(spree_product)
    exporter = Spree::Retail::Shopify::BundledProductExporter.new(spree_product: spree_product)
    shopify_product = exporter.perform
    spree_product.reload

    shopify_product
  end

  def update_product!(spree_product)
    updater = Spree::Retail::Shopify::ProductUpdater.new(spree_product: spree_product)
    shopify_product = updater.perform
    spree_product.reload

    shopify_product
  end

  def update_stock!(spree_variant)
    updater = Spree::Retail::Shopify::StockUpdater.new(spree_variant: spree_variant)
    shopify_variant = updater.perform
    spree_variant.reload

    shopify_variant
  end

  def update_variant!(spree_variant)
    updater = Spree::Retail::Shopify::VariantUpdater.new(spree_variant: spree_variant)
    shopify_variant = updater.perform
    spree_variant.reload

    shopify_variant
  end
end
