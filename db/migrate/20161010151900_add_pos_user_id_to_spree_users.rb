class AddPosUserIdToSpreeUsers < ActiveRecord::Migration
  def change
    add_column :spree_users, :pos_user_id, :string
    add_index :spree_users, :pos_user_id
  end
end
