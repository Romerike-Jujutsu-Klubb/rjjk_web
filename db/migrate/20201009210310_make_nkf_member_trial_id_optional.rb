# frozen_string_literal: true

class MakeNkfMemberTrialIdOptional < ActiveRecord::Migration[6.0]
  def change
    change_column_null :signups, :nkf_member_trial_id, true
  end
end
