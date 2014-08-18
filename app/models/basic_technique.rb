class BasicTechnique < ActiveRecord::Base
  belongs_to :rank
  belongs_to :waza
  has_many :basic_technique_links, dependent: :destroy

  validates_presence_of :name, :waza_id
  validates_uniqueness_of :name, case_sensitive: false
end
