# frozen_string_literal: true

class CreateEventGroups < ActiveRecord::Migration[4.2]
  def change
    create_table :events_groups do |t|
      t.integer :event_id
      t.integer :group_id
      t.timestamps
    end
  end
end
