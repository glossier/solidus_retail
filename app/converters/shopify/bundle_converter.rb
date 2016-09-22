module Shopify
  class BundleConverter
    def initialize(bundle:, option_types:)
      @bundle = bundle
      @option_types = option_types
    end

    def to_hash
      hash = base_product_hash.merge(all_option_types)

      hash
    end

    def base_product_hash
      { title: bundle.name,
        body_html: bundle.description,
        created_at: bundle.created_at,
        updated_at: bundle.updated_at,
        published_at: bundle.available_on,
        vendor: bundle.vendor,
        handle: bundle.slug }
    end

    private

    attr_reader :bundle, :option_types

    def all_option_types
      options = { options: [] }
      option_types.each do |option_type|
        options[:options] << { name: option_type }
      end
      options
    end
  end
end
