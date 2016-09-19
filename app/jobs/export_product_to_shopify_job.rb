require 'active_job'

class ExportProductToShopifyJob < ActiveJob::Base
  queue_as :default

  def perform(product_id)
    exporter = Shopify::ProductExporter.new(product_id)
    exporter.perform
  end
end
