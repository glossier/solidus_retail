module Shopify
  class ProductExporter
    def initialize(spree_product_id, factory = nil, logger = nil)
      @logger = logger || default_logger
      @factory = factory || default_factory
      @spree_product = Spree::Product.find(spree_product_id)
      @original_shopify_product = find_or_initialize(spree_product)
    end

    def perform
      # NOTE(cab): Refactor the new.perform to use call?
      shopify_product = factory.new(spree_product, original_shopify_product).perform
      if shopify_product.save
        save_pos_product_id(spree_product, shopify_product)
        save_pos_variant_ids(spree_product.variants, shopify_product.variants)
        save_shopify_product_images(shopify_product, spree_product.variants)
        logger.info("#{shopify_product.handle} imported")
      else
        logger.error("#{shopify_product.handle} not imported, reason: #{shopify_product.errors.full_messages}")
      end

      shopify_product
    end

    attr_accessor :logger, :factory, :spree_product, :original_shopify_product

    private

    def save_pos_product_id(product, shopify_product)
      product.pos_product_id = shopify_product.id
      product.save
    end

    def save_pos_variant_ids(spree_variants, shopify_variants)
      return if spree_variants.empty?
      shopify_variants.each do |shopify_variant|
        spree_variant = spree_variants.find_by(sku: shopify_variant.sku)
        spree_variant.pos_variant_id = shopify_variant.id
        spree_variant.save
      end
    end

    def save_shopify_product_images(shopify_product, spree_variants)
      shopify_product.images = build_images(spree_variants)
      shopify_product.save if shopify_product.images.present?
    end

    def build_images(spree_variants)
      return [] if spree_variants.empty?
      images = []

      spree_variants.each do |variant|
        variant.reload
        next if variant.images.empty?
        factory = ProductImageFactory.new(variant)
        images << factory.perform
      end

      images
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
