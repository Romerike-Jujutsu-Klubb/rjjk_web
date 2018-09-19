# frozen_string_literal: true

class AddStatusToAttendance < ActiveRecord::Migration[4.2]
  def change
    add_column :attendances, :status, :string, limit: 1
    reversible { |dir| dir.up { execute "UPDATE attendances SET status = 'X'" } }
    change_column_null :attendances, :status, false
  end
end
