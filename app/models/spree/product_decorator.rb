module Spree
  module ProductDecorator
    def self.prepended(base)
      base.after_save :export_to_shopify
    end

    private

    def export_to_shopify
      ExportProductToShopifyJob.perform_later(id)
    end
  end
end

Spree::Product.prepend Spree::ProductDecorator
