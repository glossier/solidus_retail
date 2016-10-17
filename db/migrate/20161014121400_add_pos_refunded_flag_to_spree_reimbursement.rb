class AddPosRefundedFlagToSpreeReimbursement < ActiveRecord::Migration
  def change
    add_column :spree_reimbursements, :pos_refunded, :boolean, default: false
  end
end
