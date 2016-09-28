module Spree
  module Retail
    class BundledProductAttributes
      include Spree::Retail::PresenterHelper

      def initialize(bundle, product_converter: Shopify::BundleConverter,
                     part_attributes: Shopify::PartAttributes,
                     permuter: Spree::Retail::BundlePermuter)

        @bundle = bundle
        @converter = product_converter
        @part_attributes = part_attributes
        @permuter = permuter
      end

      def attributes
        option_types = permuter.all_option_types_for(bundle)
        hash = converter.new(bundle: presented_bundle, option_types: option_types).to_hash
        hash.merge!(parts_attributes)
      end

      private

      attr_reader :bundle, :converter, :part_attributes, :permuter

      def presented_bundle
        present(bundle, :product)
      end

      def parts_attributes
        attrs_var = { variants: [] }

        permutations = permuter.all_option_values_permutation(bundle)
        permutations.each do |permutation|
          attrs_var[:variants] << part_attributes_for(permutation)
        end

        attrs_var
      end

      def part_attributes_for(permutation)
        part_attributes.new(part: master_part, permutation: permutation).attributes
      end

      def master_part
        bundle.master
      end
    end
  end
end
