class AddPosVariantIdToVariants < ActiveRecord::Migration
  def change
    add_column :spree_variants, :pos_variant_id, :string
    add_index :spree_variants, :pos_variant_id
  end
end
