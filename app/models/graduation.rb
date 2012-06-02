class Graduation < ActiveRecord::Base
  belongs_to :martial_art
  has_many :censors
  has_many :graduates

  validates_presence_of :martial_art
end
