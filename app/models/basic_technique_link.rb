# frozen_string_literal: true

class BasicTechniqueLink < ApplicationRecord
  acts_as_list scope: :basic_technique_id, sequential_updates: true

  belongs_to :basic_technique

  validates :basic_technique_id, :url, presence: true
  # validates :position, presence: true
  validates :title, length: { maximum: 64, allow_nil: true }
  validates :url, length: { in: 12..128 }
  # validates :position, uniqueness: { scope: :basic_technique_id }
  validates :url, uniqueness: { scope: :basic_technique_id }
end
