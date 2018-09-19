# frozen_string_literal: true

class CreateGroupSchedules < ActiveRecord::Migration[4.2]
  def self.up
    create_table :group_schedules do |t|
      t.integer :group_id, null: false
      t.integer :weekday, null: false
      t.time :start_at, null: false
      t.time :end_at, null: false

      t.timestamps
    end

    GroupSchedule.create! group_id: 2, weekday: 2, start_at: '17:45', end_at: '18:45'
    GroupSchedule.create! group_id: 3, weekday: 2, start_at: '19:00', end_at: '20:30'
    GroupSchedule.create! group_id: 4, weekday: 2, start_at: '19:00', end_at: '21:00'
    GroupSchedule.create! group_id: 2, weekday: 4, start_at: '17:45', end_at: '18:45'
    GroupSchedule.create! group_id: 3, weekday: 4, start_at: '19:00', end_at: '20:30'
    GroupSchedule.create! group_id: 4, weekday: 4, start_at: '19:00', end_at: '21:00'
    GroupSchedule.create! group_id: 1, weekday: 5, start_at: '18:00', end_at: '19:00'
  end

  def self.down
    drop_table :group_schedules
  end

  class GroupSchedule < ApplicationRecord
    belongs_to :group
  end
end
