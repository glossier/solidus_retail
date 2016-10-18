class AddPosCustomerIdToSpreeUser < ActiveRecord::Migration
  def change
    add_column :spree_users, :pos_customer_id, :string
  end
end
