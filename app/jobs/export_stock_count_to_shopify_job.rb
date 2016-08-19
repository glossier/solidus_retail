require 'active_job'

class ExportStockCountToShopify < ActiveJob::Base
  queue_as :high

  def perform(variant_id)
    exporter = Shopify::StockExporter.new(variant_id)
    exporter.perform
  end
end
