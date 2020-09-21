# frozen_string_literal: true

class MakeSignupNkfMemberTrialIdUnique < ActiveRecord::Migration[6.0]
  def change
    remove_index :signups, :nkf_member_trial_id
    add_index :signups, :nkf_member_trial_id, unique: true
  end
end
