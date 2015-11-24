class Censor < ActiveRecord::Base
  belongs_to :graduation
  belongs_to :member

  validates_presence_of :graduation, :graduation_id, :member, :member_id

  def approved?
    !!approved_grades_at
  end
end
