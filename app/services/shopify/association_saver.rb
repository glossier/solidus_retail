module Shopify
  class AssociationSaver
    class << self
      def save_pos_variant_id_for_variants(spree_variants, shopify_variants)
        shopify_variants.each do |shopify_variant|
          spree_variant = spree_variants.find_by(sku: shopify_variant.sku)
          next if spree_variant.nil?

          save_pos_variant_id(spree_variant, shopify_variant)
        end
      end

      def save_pos_variant_id(spree_variant, shopify_variant)
        spree_variant.pos_variant_id = shopify_variant.id
        spree_variant.save
      end

      def save_pos_product_id(spree_product, shopify_product)
        spree_product.pos_product_id = shopify_product.id
        spree_product.save
      end
    end
  end
end
