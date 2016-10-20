class AddPosAttributeToSpreeOrder < ActiveRecord::Migration
  def change
    # NOTE: This field already exists on some of our host projects.
    unless column_exists? :spree_orders, :pos
      add_column :spree_orders, :pos, :boolean
    end
  end
end
