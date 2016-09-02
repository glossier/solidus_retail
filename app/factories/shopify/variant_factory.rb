module Shopify
  class VariantFactory
    def initialize(spree_variant:, variant_api: nil, logger: nil)
      @spree_variant = spree_variant
      @variant_api = variant_api || default_variant_api
      @logger = logger || default_logger
    end

    def perform
      return variant_api.new unless spree_variant.pos_variant_id.present?

      # NOTE: Shopify doesn't offer a non-whiny version of this.
      begin
        return variant_api.find(spree_variant.pos_variant_id)
      rescue ActiveResource::ResourceNotFound
        logger.error("Variant with sku: #{spree_variant.sku} not found with id: #{spree_variant.pos_variant_id} -- Re-creating!")
      end

      variant_api.new
    end

    private

    attr_reader :spree_variant, :variant_api

    def default_variant_api
      ShopifyAPI::Variant
    end

    def default_logger
      Logger.new(Rails.root.join('log/export_solidus_products.log'))
    end
  end
end
