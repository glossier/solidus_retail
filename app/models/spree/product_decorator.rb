module Spree
  module ProductDecorator
    attr_accessor :disable_shopify_sync

    def self.prepended(base)
      base.after_create :create_shopify_product, if: :should_export_to_shopify?
      base.after_update :update_shopify_product, if: :should_export_to_shopify?
      base.after_destroy :destroy_shopify_product, if: :should_export_to_shopify?
    end

    private

    def create_shopify_product
      service = Shopify::ProductExporter.new(spree_product: self)
      service.perform
    end

    def update_shopify_product
      if assembly?
        service = Shopify::BundledProductExporter.new(spree_product: self)
      else
        service = Shopify::ProductUpdater.new(spree_product_id: id)
      end

      service.perform
    end

    def destroy_shopify_product
      return false if pos_product_id.nil?

      shopify_product = ShopifyAPI::Product.find_by_id(pos_product_id)
      shopify_product.present? ? shopify_product.destroy : false
    end

    def should_export_to_shopify?
      disable_shopify_sync != true
    end
  end
end

Spree::Product.prepend Spree::ProductDecorator
