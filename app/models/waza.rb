class Waza < ActiveRecord::Base
  attr_accessible :description, :name, :translation

  has_many :basic_techniques

  validates_uniqueness_of :name, allow_blank: false, case_sensitive: false
end
