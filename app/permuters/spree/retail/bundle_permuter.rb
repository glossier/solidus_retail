module Spree
  module Retail
    class BundlePermuter
      class << self
        def all_option_values_per_part(part)
          container = []

          part.product.variants.each do |variant|
            if variant.option_values.empty?
              container << dummy_option_value_per_variant(variant)
            else
              container << option_value_per_variant(variant)
            end
          end

          container
        end

        def all_option_values_per_bundle(bundle)
          option_values = []

          bundle.variants.first.parts.each do |part|
            values = all_option_values_per_part(part)
            option_values << values if values.any?
          end

          option_values
        end

        def all_option_values_permutation(bundle)
          initial_array, *rest_of_arrays = all_option_values_per_bundle(bundle)
          return [] if initial_array.nil?

          initial_array.product(*rest_of_arrays)
        end

        def all_option_types_for(bundle)
          all_option_values_per_bundle(bundle).map{ |p| p.first[:option_type_text] }
        end

        private

        attr_reader :bundle

        def option_value_per_variant(variant)
          option_value = variant.option_values.first
          option_type = option_value.option_type

          {
            sku: variant.sku,
            option_type_text: option_type_string_for(option_type),
            option_value_text: option_value_string_for(option_value)
          }
        end

        def dummy_option_value_per_variant(variant)
          {
            sku: variant.sku,
            option_type_text: "option#{variant.product.name}",
            option_value_text: "n/a"
          }
        end

        def option_value_string_for(option_value)
          option_value.presentation
        end

        def option_type_string_for(option_type)
          option_type.name
        end
      end
    end
  end
end
