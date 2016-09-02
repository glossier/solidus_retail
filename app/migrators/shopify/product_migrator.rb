module Shopify
  class ProductMigrator
    def initialize(spree_product:, variant_converter: nil, product_converter: nil, variant_factory: nil, product_factory: nil)
      @spree_product = spree_product
      @variant_converter = variant_converter || default_variant_converter
      @product_converter = product_converter || default_product_converter
      @variant_factory = variant_factory || default_variant_factory
      @product_factory = product_factory || default_product_factory
      @variant_presenter = variant_presenter || default_variant_presenter
      @product_presenter = product_presenter || default_product_presenter
    end

    def perform
      shopify_product = convert_to_shopify_product(spree_product)
      shopify_variants = shopify_variants_for(spree_product)
      shopify_product.variants = shopify_variants

      shopify_product
    end

    private

    attr_accessor :spree_product, :variant_converter, :product_converter,
                  :variant_factory, :product_factory,
                  :variant_presenter, :product_presenter

    def convert_to_shopify_product(spree_product)
      shopify_product = find_or_initialize_shopify_product_for(spree_product)
      presented_product = product_presenter.new(spree_product)
      product_converter.new(spree_product: presented_product, shopify_product: shopify_product).perform
    end

    def convert_to_shopify_variant(spree_variant)
      shopify_variant = find_or_initialize_shopify_variant_for(spree_variant)
      presented_variant = variant_presenter.new(spree_variant)
      variant_converter.new(spree_variant: presented_variant, shopify_variant: shopify_variant).perform
    end

    def shopify_variants_for(spree_product)
      shopify_variants = []
      product_variants_for(spree_product).each do |spree_variant|
        shopify_variants << convert_to_shopify_variant(spree_variant)
      end

      shopify_variants
    end

    def product_variants_for(spree_product)
      spree_product.variants_including_master
    end

    def find_or_initialize_shopify_variant_for(spree_variant)
      variant_factory.new(spree_variant: spree_variant).perform
    end

    def find_or_initialize_shopify_product_for(spree_product)
      product_factory.new(spree_product: spree_product).perform
    end

    def default_product_converter
      Shopify::ProductConverter
    end

    def default_variant_converter
      Shopify::VariantConverter
    end

    def default_product_factory
      Shopify::ProductFactory
    end

    def default_variant_factory
      Shopify::VariantFactory
    end

    def default_product_presenter
      Shopify::ProductPresenter
    end

    def default_variant_presenter
      Shopify::VariantPresenter
    end
  end
end
