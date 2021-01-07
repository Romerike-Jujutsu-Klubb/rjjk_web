# frozen_string_literal: true

class RemoveNkfTables < ActiveRecord::Migration[6.0]
  def up
    remove_column :members, :nkf_fee
    remove_column :signups, :nkf_member_trial_id
    drop_table :nkf_member_trials
    drop_table :nkf_members
  end
end
