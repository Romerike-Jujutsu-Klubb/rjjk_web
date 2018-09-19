# frozen_string_literal: true

class AddApprovalRequestedAtToCensors < ActiveRecord::Migration[4.2]
  def change
    add_column :censors, :approval_requested_at, :datetime
  end
end
