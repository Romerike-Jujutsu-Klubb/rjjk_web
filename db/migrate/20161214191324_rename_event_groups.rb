# frozen_string_literal: true
class RenameEventGroups < ActiveRecord::Migration
  def change
    rename_table :events_groups, :event_groups
    change_column_null :event_groups, :event_id, false
    change_column_null :event_groups, :group_id, false
  end
end
