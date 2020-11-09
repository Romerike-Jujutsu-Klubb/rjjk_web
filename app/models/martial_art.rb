# frozen_string_literal: true

class MartialArt < ApplicationRecord
  belongs_to :original_martial_art, class_name: :MartialArt, optional: true

  # has_many :graduations, -> { order(:held_on) }, through: :groups
  has_many :curriculum_groups, dependent: :destroy

  has_many :copies, class_name: :MartialArt, foreign_key: :original_martial_art_id,
      inverse_of: :original_martial_art, dependent: :restrict_with_error
  has_many :ranks, -> { order 'curriculum_groups.position', 'ranks.position' }, through: :curriculum_groups

  validates :name, :family, presence: true
  validates :name, uniqueness: { case_sensitive: false }

  scope :kwr, -> { where(name: KWR_NAME) }
  scope :originals, -> { references(:martial_arts).where(original_martial_art_id: nil) }

  KWR_NAME = 'Kei Wa Ryu'
  KWR_ID = originals.find_by(name: KWR_NAME)&.id || ActiveRecord::FixtureSet.identify(:keiwaryu)

  def kwr?
    name == KWR_NAME
  end

  def to_s
    name
  end

  def archived?
    original_martial_art_id
  end
end
