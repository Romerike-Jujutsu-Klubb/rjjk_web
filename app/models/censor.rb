class Censor < ActiveRecord::Base
  #attr_accessible :approved_grades_at, :confirmed_at, :graduation_id, :member_id

  belongs_to :graduation
  belongs_to :member

  validates_presence_of :graduation, :graduation_id, :member, :member_id
end
