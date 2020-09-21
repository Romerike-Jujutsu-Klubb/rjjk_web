# frozen_string_literal: true

class AddKjonnToNkfMemberTrials < ActiveRecord::Migration[6.0]
  def change
    add_column :nkf_member_trials, :kjonn, :string, null: false, default: 'M'
    change_column_default :nkf_member_trials, :kjonn, from: 'M', to: nil
  end
end
