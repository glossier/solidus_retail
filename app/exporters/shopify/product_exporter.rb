module Shopify
  class ProductExporter
    def initialize(spree_product_id:, product_class: nil, logger: nil, product_migrator: nil)
      @logger = logger || default_logger
      @product_class = product_class || default_product_class

      @spree_product = @product_class.find(spree_product_id)
      @product_migrator = product_migrator || default_product_migrator
      @migrator = @product_migrator.new(spree_product: @spree_product)
    end

    def perform
      shopify_product = migrator.perform
      if shopify_product.save
        save_pos_product_id(spree_product, shopify_product)
        logger.info("#{shopify_product.handle} imported")
      else
        logger.error("#{shopify_product.handle} not imported, reason: #{shopify_product.errors.full_messages}")
      end

      shopify_product
    end

    private

    attr_accessor :logger, :spree_product, :product_class, :migrator

    def save_pos_product_id(product, shopify_product)
      product.pos_product_id = shopify_product.id
      product.save
    end

    def default_logger
      Logger.new(Rails.root.join('log/export_solidus_products.log'))
    end

    def default_product_class
      Spree::Product
    end

    def default_product_migrator
      Shopify::ProductMigrator
    end
  end
end
