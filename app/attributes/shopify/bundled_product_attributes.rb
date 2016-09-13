module Shopify
  class BundledProductAttributes
    include Spree::Retail::PresenterHelper

    def initialize(spree_product, product_converter: Shopify::ProductConverter,
                   variant_attributes: Shopify::VariantAttributes)

      @spree_product = spree_product
      @converter = product_converter
      @variant_attributes = variant_attributes
    end

    def attributes
      hash = converter.new(product: presented_product).to_hash
      permutations = Spree::Retail::BundlePermuter.all_option_values_permutation(spree_product)
      hash.merge!(add_option_type(permutations))
      hash.merge!(attrs)
      hash
    end

    def attrs
      attrs_var = { variants: [] }

      permutations = Spree::Retail::BundlePermuter.all_option_values_permutation(spree_product)
      permutations.each do |permutation|
        attrs_var[:variants] << master_variant_attributes.merge(add_option(permutation).reduce({}, :merge))
        attrs_var[:variants].last[:sku] = generate_variant_sku_from_permutation(permutation)
        attrs_var[:variants].last[:option1] = generate_variant_sku_from_permutation(permutation)
      end

      attrs_var
    end

    def add_option_type(permutation)
      options = { options: [] }
      permutation.first.each_with_index do |permu, index|
        options[:options] << { name: permu[:option_type_text] }
      end
      options
    end

    def add_option(permutation)
      perms = []
      permutation.each_with_index do |permu, index|
        perms << { "option#{index+1}" => permu[:option_value_text] }
      end
      perms
    end

    def generate_variant_sku_from_permutation(permutation)
      sku = master_variant.sku
      permutation_skus = permutation.map { |perm| perm[:sku] }.join('/')
      "#{sku}/#{permutation_skus}"
    end

    def master_variant_attributes
      variant_attributes.new(spree_product.master).attributes
    end

    def master_variant
      spree_product.master
    end

    private

    attr_reader :spree_product, :converter, :variant_attributes

    def presented_product
      present(spree_product, :product)
    end
  end
end
