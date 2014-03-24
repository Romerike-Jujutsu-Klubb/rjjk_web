class TechniqueApplication < ActiveRecord::Base
  attr_accessible :kata, :name, :rank_id

  belongs_to :rank
  has_many :application_steps, dependent: :destroy

  validates_presence_of :name
  validates_uniqueness_of :name, scope: :rank_id, case_sensitive: false
end
