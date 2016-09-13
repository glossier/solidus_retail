module Spree
  module Retail
    class BundlePermuter
      include Spree::Retail::PresenterHelper

      class << self

        def all_option_values_per_part(part)
          container = []

          part.product.variants.each do |variant|
            container << option_value_per_variant(variant)
          end

          container
        end

        def all_option_values_per_bundle(bundle)
          option_values = []

          bundle.parts.each do |part|
            option_values << all_option_values_per_part(part)
          end

          option_values
        end

        def all_option_values_permutation(bundle)
          initial_array, *rest_of_arrays = all_option_values_per_bundle(bundle)
          initial_array.product(*rest_of_arrays)
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
