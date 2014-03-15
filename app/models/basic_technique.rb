class BasicTechnique < ActiveRecord::Base
  attr_accessible :description, :name, :rank_id, :translation, :waza_id

  belongs_to :rank
  belongs_to :waza

  validates_presence_of :name, :waza_id
  validates_uniqueness_of :name, case_sensitive: false
end
