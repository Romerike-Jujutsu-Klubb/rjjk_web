# frozen_string_literal: true

class TechniqueApplication < ApplicationRecord
  module System
    KATA = 'Kata'
  end

  acts_as_list scope: :rank_id

  belongs_to :rank
  has_many :application_steps, dependent: :destroy
  has_many :application_videos, dependent: :destroy

  validates :name, presence: true
  validates :name, uniqueness: { scope: :rank_id, case_sensitive: false }
end
