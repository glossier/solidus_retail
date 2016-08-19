namespace :shopify do
  desc "Export stock count to shopify"
  task export_stock_count: :environment do
    Spree::Variant.all.each do |variant|
      next if spree_variant.pos_variant_id.nil?
      ExportStockCountToShopify.perform_later(variant.id)
    end
  end
end
