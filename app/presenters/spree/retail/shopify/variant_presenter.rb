module Spree
  module Retail
    module Shopify
      class VariantPresenter < Delegator
        def weight_unit
          'oz'
        end

        def default_pos_image
          images.first
        end

        def title
          return sku unless option_values.any?

          option_values.first.presentation
        end
      end
    end
  end
end
