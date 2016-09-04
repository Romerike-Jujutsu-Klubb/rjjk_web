# frozen_string_literal: true
class Censor < ActiveRecord::Base
  belongs_to :graduation
  belongs_to :member

  validates :graduation, :graduation_id, :member, :member_id, presence: true

  def approved?
    !!approved_grades_at
  end
end
