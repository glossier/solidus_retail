module Spree
  module Retail
    module Shopify
      class ProductAttributes
        include PresenterHelper

        def initialize(spree_product, product_converter: ProductConverter,
                       image_attributor: ImageAttributes,
                       variant_attributor: VariantAttributes)

          @spree_product = spree_product
          @converter = product_converter
          @variant_attributor = variant_attributor
          @image_attributor = image_attributor
        end

        def attributes
          converter.new(product: presented_product).to_hash
        end

        def attributes_with_variants
          attributes.merge(attributes_for_variants)
        end

        def attributes_with_images
          attributes.merge(attributes_for_images)
        end

        private

        attr_reader :spree_product, :converter, :variant_attributor, :image_attributor

        def presented_product
          present(spree_product, :product)
        end

        def attributes_for_variants
          attributes = { variants: [] }

          variant_scope.each do |variant|
            attributes[:variants] << variant_attributor.new(variant).attributes
          end

          attributes
        end

        def attributes_for_images
          attributes = { images: [] }

          variant_scope.each do |variant|
            attributes[:images] << image_attributor.new(variant).attributes
          end

          attributes
        end

        def variant_scope
          spree_product.variants_including_master
        end
      end
    end
  end
end
