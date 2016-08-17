# frozen_string_literal: true
class Waza < ActiveRecord::Base
  has_many :basic_techniques

  validates_uniqueness_of :name, allow_blank: false, case_sensitive: false
end
