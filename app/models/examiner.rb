class Examiner < ActiveRecord::Base
  attr_accessible :approved_grades_at, :confirmed_at, :graduation_id, :member_id

  belongs_to :graduation
  belongs_to :member

  validates_presence_of :graduation_id
  validates_presence_of :member_id
  validates_presence_of :member, :if => :member_id
end
