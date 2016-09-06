module Shopify
  class ProductMigrator
    def initialize(spree_product:, product_converter: nil)
      @spree_product = spree_product
      @product_converter = product_converter || default_product_converter
      @product_presenter = product_presenter || default_product_presenter
    end

    def perform
      shopify_product = convert_to_shopify_product(spree_product)

      shopify_product
    end

    private

    attr_accessor :spree_product, :product_converter, :product_factory, :product_presenter

    def convert_to_shopify_product(spree_product)
      shopify_product = ShopifyAPI::Product.find_or_initialize_by(id: spree_product.pos_product_id)
      presented_product = product_presenter.new(spree_product)
      product_converter.new(spree_product: presented_product, shopify_product: shopify_product).perform
    end

    def find_or_initialize_shopify_product_for(spree_product)
      product_factory.new(spree_product: spree_product).perform
    end

    def default_product_converter
      Shopify::ProductConverter
    end

    def default_product_presenter
      Shopify::ProductPresenter
    end
  end
end
