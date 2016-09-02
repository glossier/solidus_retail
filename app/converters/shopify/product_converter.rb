module Shopify
  class ProductConverter
    def initialize(spree_product:, shopify_product:, vendor: nil, variant_interface: nil, variant_converter: nil, logger: nil, renderer: nil)
      @spree_product = spree_product
      @shopify_product = shopify_product
      @vendor = vendor || default_vendor

      @logger = logger || default_logger
      @renderer = renderer || default_renderer
      @variant_interface = variant_interface || default_variant_interface
      @variant_converter = variant_converter || default_variant_converter
    end

    def perform
      shopify_product.title = spree_product.name
      shopify_product.body_html = renderer.render(spree_product.description)
      shopify_product.created_at = spree_product.created_at
      shopify_product.updated_at = spree_product.updated_at
      shopify_product.published_at = spree_product.available_on
      shopify_product.vendor = vendor
      shopify_product.handle = spree_product.slug
      shopify_product.variants = build_variants(spree_product)

      shopify_product
    end

    private

    attr_accessor :spree_product, :shopify_product, :vendor, :logger,
                  :renderer, :variant_interface, :variant_converter

    def build_variants(spree_product)
      variants = [build_variant(spree_product.master)]

      spree_product.variants.each do |variant|
        variants << build_variant(variant)
      end

      variants
    end

    def build_variant(variant)
      shopify_variant = find_or_initialize_variant(variant)
      variant_converter.new(spree_variant: variant, shopify_variant: shopify_variant).perform
    end

    def find_or_initialize_variant(spree_variant)
      # NOTE: Shopify doesn't offer a non-whiny version of this.
      begin
        shopify_variant = variant_interface.find(spree_variant.pos_variant_id) if spree_variant.pos_variant_id
      rescue ActiveResource::ResourceNotFound
        logger.error("Variant with sku: #{spree_variant.sku} not found with id: #{spree_variant.pos_variant_id} -- Re-creating!")
      end
      shopify_variant = variant_interface.new if shopify_variant.nil?
      shopify_variant
    end

    def default_logger
      Logger.new(Rails.root.join('log/export_solidus_products.log'))
    end

    def default_vendor
      'Default Vendor'
    end

    def default_renderer
      Shopify::RedcarpetHTMLRenderer.new
    end

    def default_variant_converter
      Shopify::VariantConverter
    end

    def default_variant_interface
      ShopifyAPI::Variant
    end
  end
end
