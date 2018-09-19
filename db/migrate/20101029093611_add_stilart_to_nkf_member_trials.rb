# frozen_string_literal: true

class AddStilartToNkfMemberTrials < ActiveRecord::Migration[4.2]
  def self.up
    add_column :nkf_member_trials, :stilart, :string, limit: 64
    execute "UPDATE nkf_member_trials SET stilart = 'Jujutsu (Ingen stilartstilknytning)'"
    change_column_null :nkf_member_trials, :stilart, false
  end

  def self.down
    remove_column :nkf_member_trials, :stilart
  end
end
