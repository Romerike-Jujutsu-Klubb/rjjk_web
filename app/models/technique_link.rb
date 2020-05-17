# frozen_string_literal: true

class TechniqueLink < ApplicationRecord
  acts_as_list scope: %i[linkable_type linkable_id], sequential_updates: true

  belongs_to :linkable, polymorphic: true

  validates :linkable_id, :linkable_type, :url, presence: true
  # validates :position, presence: true
  validates :title, length: { maximum: 64, allow_nil: true }
  validates :url, length: { in: 12..128 }
  validates :url, format: URI::DEFAULT_PARSER.make_regexp(%w[http https])
  # validates :position, uniqueness: { scope: [:linkable_type,:linkable_id] }
  validates :url, uniqueness: { scope: %i[linkable_type linkable_id], case_sensitive: false }

  def label
    title.presence || url
  end
end
