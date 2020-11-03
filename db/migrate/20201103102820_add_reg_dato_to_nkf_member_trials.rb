# frozen_string_literal: true

class AddRegDatoToNkfMemberTrials < ActiveRecord::Migration[6.0]
  def change
    add_column :nkf_member_trials, :reg_dato, :date, null: false, default: Date.current
    change_column_default :nkf_member_trials, :reg_dato, from: Date.current, to: nil
  end
end
