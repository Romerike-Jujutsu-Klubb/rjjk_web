class Censor < ActiveRecord::Base
  belongs_to :member
  
  validates_presence_of :member
  validates_presence_of :member_id
end
