class Rank < ActiveRecord::Base
  belongs_to :martial_art

  validates_presence_of :position, :standard_months
  validates_uniqueness_of :position
end
