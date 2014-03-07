class Appointment < ActiveRecord::Base
  attr_accessible :from, :member_id, :role_id, :to
  belongs_to :member
  belongs_to :role

  scope :current,
      -> { where('"from" <= ? AND ("to" IS NULL OR "to" >= ?)',
          *([Date.today]*2)) }
end
