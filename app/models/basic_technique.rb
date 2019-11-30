# frozen_string_literal: true

class BasicTechnique < ApplicationRecord
  belongs_to :rank
  belongs_to :waza
  has_many :basic_technique_links, dependent: :destroy

  before_validation { description.strip! }

  validates :name, :waza_id, presence: true
  validates :name, uniqueness: { case_sensitive: false }
end
