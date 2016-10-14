class AddPosRefundedFlagToSpreeReimbursement < ActiveRecord::Migration
  def change
    add_column :spree_reimbursements, :pos_refunded, :bool, default: false
  end
end
