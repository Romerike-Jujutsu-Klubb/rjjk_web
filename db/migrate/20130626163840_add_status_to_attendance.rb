class AddStatusToAttendance < ActiveRecord::Migration
  def change
    add_column :attendances, :status, :string, limit: 1
    execute "UPDATE attendances SET status = 'X'"
    change_column_null :attendances, :status, false
  end
end
