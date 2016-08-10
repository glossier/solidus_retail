class AddPosOrderIdToOrders < ActiveRecord::Migration
  def change
    add_column :spree_orders, :pos_order_id, :string
    add_index :spree_orders, :pos_order_id
  end
end
