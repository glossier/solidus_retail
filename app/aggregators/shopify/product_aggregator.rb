module Shopify
  class ProductAggregator
    def initialize(product_attributes:)
      @attributes = product_attributes
    end

    def merge_master_variant(variant_attributes)
      # By default the product_id is nil in the attributes.
      # This causes problem when trying to assign the attributes to the product
      # directly as it throws a 500 error.
      variant_attributes.except!(:product_id)

      # The first variant is considered the "master" one, in our perspective.
      # Shopify doesn't care about the order
      attributes.merge!(variant: [variant_attributes])
    end

    attr_accessor :attributes
  end
end
