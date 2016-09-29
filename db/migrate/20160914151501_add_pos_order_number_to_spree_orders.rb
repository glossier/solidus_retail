class AddPosOrderNumberToSpreeOrders < ActiveRecord::Migration
  def change
    add_column :spree_orders, :pos_order_number, :string
  end
end
