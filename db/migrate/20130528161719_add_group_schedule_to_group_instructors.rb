# frozen_string_literal: true

class AddGroupScheduleToGroupInstructors < ActiveRecord::Migration
  def change
    execute 'DELETE FROM group_instructors'
    add_column :group_instructors, :group_schedule_id, :integer, null: false # rubocop:disable Rails/NotNullColumn
    remove_column :group_instructors, :group_id
    add_column :group_instructors, :to, :date
  end
end
