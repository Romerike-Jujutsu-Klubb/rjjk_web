class Appointment < ActiveRecord::Base
  belongs_to :member
  belongs_to :role

  scope :current, -> { where('"from" <= ? AND ("to" IS NULL OR "to" >= ?)',
      *([Date.today]*2)) }
end
