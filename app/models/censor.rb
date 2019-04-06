# frozen_string_literal: true

class Censor < ApplicationRecord
  belongs_to :graduation
  belongs_to :member

  validates :graduation, :graduation_id, :member, :member_id, presence: true
  validate do
    if approved_grades_at && graduation.graduates.any? { |g| g.passed.nil? }
      errors.add :base, 'Du må sette "bestått Ja/Nei" på alle kandidatene.'
    end
  end

  scope :examiners, -> { where examiner: true }
  scope :confirmed, -> { where(declined: false) }

  def confirmed?
    confirmed_at? && !declined?
  end

  def approved_graduates?
    !!locked_at
  end

  def approved?
    !!approved_grades_at
  end

  def role_name
    examiner ? 'eksaminator' : 'sensor'
  end

  def should_lock?
    locked_at.nil? &&
        ((examiner? && graduation.held_on < GraduationReminder::CHIEF_INSTRUCTOR_LOCK_LIMIT.from_now) ||
            (graduation.held_on < GraduationReminder::CHIEF_INSTRUCTOR_LOCK_LIMIT.from_now &&
                member_id == graduation.group.group_semesters.for_date(graduation.held_on).first
                    .chief_instructor_id))
  end
end
