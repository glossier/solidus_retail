namespace :shopify do
  task export_products: :environment do
    Spree::Product.all.each do |product|
      exporter = Shopify::ProductExporter.new(product.id)
      exporter.perform
    end
  end
end
