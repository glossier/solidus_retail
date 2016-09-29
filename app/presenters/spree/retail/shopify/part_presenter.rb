module Spree
  module Retail
    module Shopify
      class PartPresenter < Delegator
        attr_accessor :permutation

        def weight_unit
          'oz'
        end

        def sku
          return model.sku if permutation.nil?
          generate_part_sku_from(permutation)
        end

        private

        def generate_part_sku_from(permutation)
          bundle_sku = bundle.sku
          permutation_skus = permutation.map { |p| p[:sku] }.join(sku_separator)
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
  end
end
