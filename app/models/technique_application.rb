# frozen_string_literal: true

class TechniqueApplication < ApplicationRecord
  module System
    KATA = 'Kata'
  end

  belongs_to :rank
  has_many :application_steps, dependent: :destroy

  validates :name, presence: true
  validates :name, uniqueness: { scope: :rank_id, case_sensitive: false }
end
