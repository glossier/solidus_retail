module Shopify
  class ProductExporter
    def initialize(spree_product, factory = nil, logger = nil)
      @logger = logger || default_logger
      @factory = factory || default_factory
      @spree_product = spree_product
      @shopify_product = find_or_initialize(spree_product)
    end

    def perform
      shopify_product = factory.new(spree_product, shopify_product)
      if saved = shopify_product.save
        save_pos_product_id(spree_product, shopify_product)
        logger.info("#{shopify_product.handle} imported")
      else
        logger.error("#{shopify_product.handle} not imported, reason: #{shopify_product.errors.full_messages}")
      end

      saved
    end

    attr_reader :logger, :factory, :spree_product, :shopify_product

    private

    def save_pos_product_id(product, shopify_product)
      product.pos_product_id = shopify_product.id
      product.save
    end

    def find_or_initialize(spree_product)
      shopify_product = ::ShopifyAPI::Product.find(spree_product.pos_product_id) if spree_product.pos_product_id
      shopify_product = ::ShopifyAPI::Product.new if shopify_product.nil?

      shopify_product
    end

    def default_logger
      Logger.new(Rails.root.join('log/export_solidus_products.log'))
    end

    def default_factory
      ProductFactory
    end
  end
end
