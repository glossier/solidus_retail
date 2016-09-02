module Shopify
  class ProductFactory
    def initialize(spree_product:, product_api: nil, logger: nil)
      @spree_product = spree_product
      @product_api = product_api || default_product_api
      @logger = logger || default_logger
    end

    def perform
      return product_api.new unless spree_product.pos_product_id.present?

      # NOTE: Shopify doesn't offer a non-whiny version of this.
      begin
        return product_api.find(spree_product.pos_product_id)
      rescue ActiveResource::ResourceNotFound
        logger.error("#{spree_product.slug} not found with id: #{spree_product.pos_product_id} -- Re-creating!")
      end

      product_api.new
    end

    private

    attr_reader :spree_product, :product_api, :logger

    def default_product_api
      ShopifyAPI::Product
    end

    def default_logger
      Logger.new(Rails.root.join('log/export_solidus_products.log'))
    end
  end
end
