# frozen_string_literal: true

class Waza < ActiveRecord::Base
  has_many :basic_techniques

  validates :name, uniqueness: { allow_blank: false, case_sensitive: false }
end
