class BasicTechniqueLink < ActiveRecord::Base
  attr_accessible :basic_technique_id, :position, :title, :url
  acts_as_list scope: :basic_technique_id

  belongs_to :basic_technique

  validates_presence_of :basic_technique_id, :position, :url
  validates_length_of :title, maximum: 64, allow_nil: true
  validates_length_of :url, in: 12..128
  validates_uniqueness_of :position, scope: :basic_technique_id
  validates_uniqueness_of :url, scope: :basic_technique_id
end
