module Shopify
  class ProductUpdater
    def initialize(spree_product_id:, product_klass: Spree::Product,
                   product_api: ShopifyAPI::Product,
                   attributor: Shopify::ProductAttributes,
                   exporter: Shopify::ProductExporter)

      @spree_product = product_klass.find(spree_product_id)
      @product_api = product_api
      @exporter = exporter
      @attributor = attributor
    end

    def save_product_on_shopify
      shopify_product = find_shopify_product_for(spree_product)

      if shopify_product.persisted?
        shopify_product.update_attributes(product_attributes)
        Shopify::AssociationSaver.save_pos_product_id(spree_product, shopify_product)
      else
        shopify_product = exporter.new(spree_product: spree_product).save_product_on_shopify
      end

      shopify_product
    end

    private

    attr_accessor :spree_product, :product_api, :exporter, :attributor

    def find_shopify_product_for(spree_product)
      product_api.find_or_initialize_by(id: spree_product.pos_product_id)
    end

    def product_attributes
      attributor.new(spree_product).attributes
    end
  end
end
