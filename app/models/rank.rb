class Rank < ActiveRecord::Base
  belongs_to :martial_art
  belongs_to :group

  validates_presence_of :position, :standard_months, :group, :group_id, :martial_art, :martial_art_id
  validates_uniqueness_of :position, :scope => :martial_art_id
end
