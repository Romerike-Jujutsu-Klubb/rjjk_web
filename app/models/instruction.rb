class Instruction < ActiveRecord::Base
  attr_accessible :from, :group_id, :member_id, :to

  belongs_to :group
  belongs_to :member

  validates_presence_of :from, :group, :group_id, :member, :member_id
end
