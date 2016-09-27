class AddPosAttributeToSpreeOrder < ActiveRecord::Migration
  def change
    add_column :spree_orders, :pos, :boolean
  end
end
