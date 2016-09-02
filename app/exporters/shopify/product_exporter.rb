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
        save_pos_variant_ids(spree_product, shopify_product.variants)
        # save_shopify_product_images(shopify_product, spree_product.variants)
        logger.info("#{shopify_product.handle} imported")
      else
        logger.error("#{shopify_product.handle} not imported, reason: #{shopify_product.errors.full_messages}")
      end

      shopify_product
    end

    attr_accessor :logger, :spree_product, :product_class, :migrator

    private

    def save_pos_product_id(product, shopify_product)
      product.pos_product_id = shopify_product.id
      product.save
    end

    def save_pos_variant_ids(spree_product, shopify_variants)
      shopify_variants.each do |shopify_variant|
        spree_variant = spree_product.variants_including_master.find_by(sku: shopify_variant.sku)
        next if spree_variant.nil?

        spree_variant.pos_variant_id = shopify_variant.id
        spree_variant.save
      end
    end

    # def save_shopify_product_images(shopify_product, spree_variants)
    #   shopify_product.images = build_images(spree_variants)
    #   shopify_product.save if shopify_product.images.present?
    # end
    #
    # def build_images(spree_variants)
    #   return [] if spree_variants.empty?
    #   images = []
    #
    #   spree_variants.each do |variant|
    #     variant.reload
    #     next if variant.images.empty?
    #     factory = ProductImageConverter.new(variant)
    #     images << factory.perform
    #   end
    #
    #   images
    # end
    #
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
