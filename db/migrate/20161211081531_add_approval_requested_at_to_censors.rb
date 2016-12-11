class AddApprovalRequestedAtToCensors < ActiveRecord::Migration
  def change
    add_column :censors, :approval_requested_at, :datetime
  end
end
