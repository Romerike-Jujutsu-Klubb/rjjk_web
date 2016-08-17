# frozen_string_literal: true
class CreateTrialAttendances < ActiveRecord::Migration
  def self.up
    create_table 'trial_attendances', force: true do |t|
      t.integer 'nkf_member_trial_id', null: false
      t.integer 'group_schedule_id', null: false
      t.integer 'year', null: false
      t.integer 'week', null: false
      t.datetime 'created_at'
      t.datetime 'updated_at'
    end

    add_index 'trial_attendances', %w(nkf_member_trial_id group_schedule_id year week),
              unique: true,
              name: 'ix_trial_attendances__nkf_member_trial_group_schedule_year_week'
  end

  def self.down
    drop_table 'trial_attendances'
  end
end
