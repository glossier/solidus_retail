module Shopify
  class ProductConverter
    def initialize(product:, define_options: false)
      @product = product
      @define_options = define_options
    end

    def to_hash
      hash = base_product_hash
      hash.merge!(option_types) if define_options?

      hash
    end

    def base_product_hash
      { title: product.name,
        body_html: product.description,
        created_at: product.created_at,
        updated_at: product.updated_at,
        published_at: product.available_on,
        vendor: product.vendor,
        handle: product.slug }
    end

    private

    attr_reader :product, :define_options

    def define_options?
      define_options == true
    end

    # Per the Shopify documentation:
    # A product may have a maximum of 3 options.
    # 255 characters limit each.
    def option_types
      return {} unless define_options?

      option_types = { options: [] }

      product_parts.each do |part|
        break if option_types[:options].count >= 3

        part.product.option_types.each do |option_type|
          break if option_types[:options].count >= 3

          option_types[:options] << { name: option_type.name }
        end
      end

      option_types
    end

    def product_parts
      product.parts
    end
  end
end
