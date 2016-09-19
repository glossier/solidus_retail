module Shopify
  class ProductUpdater
    def initialize(spree_product_id:, product_klass: Spree::Product,
                   product_api: ShopifyAPI::Product,
                   product_exporter: Shopify::ProductExporter)

      @spree_product = product_klass.find(spree_product_id)
      @product_api = product_api
      @product_exporter = product_exporter
    end

    def save_product_on_shopify
      shopify_product = find_shopify_product_for(spree_product)

      if shopify_product.persisted?
        shopify_product.update_attributes(product_attributes)
        save_pos_product_id(spree_product, shopify_product)
      else
        shopify_product = product_exporter.new(spree_product: spree_product).save_product_on_shopify
      end

      shopify_product
    end

    private

    attr_accessor :spree_product, :product_api, :product_exporter

    def find_shopify_product_for(spree_product)
      product_api.find_or_initialize_by_id(spree_product.pos_product_id)
    end

    # FIXME: refactor this
    def save_pos_product_id(product, shopify_product)
      product.pos_product_id = shopify_product.id
      product.save
    end

    def product_attributes
      Shopify::ProductAttributes.new(spree_product).attributes
    end
  end
end
