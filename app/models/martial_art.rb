class MartialArt < ActiveRecord::Base
  has_many :groups
  has_many :ranks, :order => :position
  
  validates_presence_of :name, :family
  validates_uniqueness_of :name, :family
end
