# frozen_string_literal: true

class Censor < ApplicationRecord
  belongs_to :graduation
  belongs_to :member

  validates :graduation, :graduation_id, :member, :member_id, presence: true
  validate do
    if approved_grades_at && graduation.graduates.any? { |g| g.passed.nil? }
      errors.add :bas, 'må sette "bestått Ja/Nei" på alle kandidatene.'
    end
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
end
