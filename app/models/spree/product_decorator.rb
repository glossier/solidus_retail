module Spree
  module ProductDecorator
    def self.prepended(base)
      base.after_create :create_shopify_product
      base.after_update :update_shopify_product
      base.after_destroy :destroy_shopify_product
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
  end
end

Spree::Product.prepend Spree::ProductDecorator
