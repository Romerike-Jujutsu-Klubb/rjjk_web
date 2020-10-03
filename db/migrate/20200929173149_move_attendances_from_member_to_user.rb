# frozen_string_literal: true

class MoveAttendancesFromMemberToUser < ActiveRecord::Migration[6.0]
  def change
    add_reference :attendances, :user, foreign_key: true
    add_index :attendances, %i[user_id practice_id], unique: true
    Attendance.all.each do |a|
      if Attendance.find_by(user_id: a.member.user_id, practice_id: a.practice_id)
        a.destroy!
      else
        a.update! user_id: a.member.user_id
      end
    end
    change_column_null :attendances, :user_id, false
    remove_column :attendances, :member_id, :bigint
    TrialAttendance.all.each do |ta|
      if ta.nkf_member_trial.signup.nil?
        new_user = User.create! ta.nkf_member_trial.user_attributes
        ta.nkf_member_trial.create_signup! user_id: new_user.id
      end
      Attendance.create! user_id: ta.nkf_member_trial.signup.user_id,
          created_at: ta.created_at,
          updated_at: ta.updated_at,
          status: 'X',
          practice_id: ta.practice_id
    end
    drop_table :trial_attendances do |t|
      t.integer 'nkf_member_trial_id', null: false
      t.datetime 'created_at'
      t.datetime 'updated_at'
      t.integer 'practice_id', null: false
      t.index %w[nkf_member_trial_id practice_id],
          name: 'index_trial_attendances_on_nkf_member_trial_id_and_practice_id', unique: true
      t.index ['practice_id'], name: 'fk__trial_attendances_practice_id'
    end
  end

  class Attendance < ApplicationRecord
    belongs_to :member, optional: true
    belongs_to :user
    belongs_to :practice
    has_one :group_schedule, through: :practice
  end

  class TrialAttendance < ApplicationRecord
    belongs_to :nkf_member_trial
    belongs_to :practice
    validates :nkf_member_trial, :practice, presence: true
  end
end
