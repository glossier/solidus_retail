module Shopify
  class PartPresenter < Delegator
    def weight_unit
      'oz'
    end

    def sku
      return model.sku if permutations.empty?
      generate_part_sku_from(permutations)
    end

    attr_accessor :permutations

    private

    def generate_part_sku_from(permutations)
      bundle_sku = bundle.sku
      permutation_skus = permutations.map { |p| p[:sku] }.join(sku_separator)
      "#{bundle_sku}#{sku_separator}#{permutation_skus}"
    end

    def bundle
      product.master
    end

    def sku_separator
      '/'
    end
  end
end
