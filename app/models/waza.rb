# frozen_string_literal: true

class Waza < ApplicationRecord
  has_many :basic_techniques, dependent: :restrict_with_exception

  validates :name, uniqueness: { allow_blank: false, case_sensitive: false }
end
