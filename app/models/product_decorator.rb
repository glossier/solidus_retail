Spree::Product.class_eval do
  after_save :export_to_shopify

  private

  def export_to_shopify
    ExportProductToShopifyJob.perform_later(id)
  end
end
