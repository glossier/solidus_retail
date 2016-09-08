module Shopify
  class ProductExporter
    include Spree::Retail::PresenterHelper

    def initialize(spree_product_id:, product_klass: Spree::Product,
                   product_api: ShopifyAPI::Product,
                   product_converter: Shopify::ProductConverter,
                   variant_converter: Shopify::VariantConverter)

      @spree_product = product_klass.find(spree_product_id)
      @product_converter = product_converter
      @variant_converter = variant_converter
      @product_api = product_api
    end

    def perform
      shopify_product = find_shopify_product_for(spree_product)

      save_product_on_shopify_for(spree_product, shopify_product)
    end

    private

    attr_accessor :spree_product, :product_api,
                  :product_converter, :variant_converter

    def save_product_on_shopify_for(spree_product, shopify_product)
      aggregator = ProductAggregator.new(product_attributes: product_attributes)
      aggregator.merge_master_variant(master_variant_attributes)
      require 'pry'; binding.pry
      shopify_product.update_attributes(aggregator.attributes)
      save_pos_product_id(spree_product, shopify_product)

      shopify_product
    end

    def find_shopify_product_for(spree_product)
      product_api.find_or_initialize_by(id: spree_product.pos_product_id)
    end

    def presented_product
      present(spree_product, :product)
    end

    def presented_variant(master_variant)
      present(master_variant, :variant)
    end

    def save_pos_product_id(product, shopify_product)
      product.pos_product_id = shopify_product.id
      product.save
    end

    def product_attributes
      product_converter.new(product: presented_product).to_hash
    end

    def master_variant_attributes
      master_variant = spree_product.master
      variant_converter.new(variant: presented_variant(master_variant)).to_hash
    end
  end
end
