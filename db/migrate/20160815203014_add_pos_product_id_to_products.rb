class AddPosProductIdToProducts < ActiveRecord::Migration
  def change
    add_column :spree_products, :pos_product_id, :string
    add_index :spree_products, :pos_product_id
  end
end
