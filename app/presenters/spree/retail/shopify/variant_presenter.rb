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
      end
    end
  end
end
