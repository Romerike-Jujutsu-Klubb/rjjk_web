# frozen_string_literal: true

class MartialArt < ApplicationRecord
  KWR_NAME = 'Kei Wa Ryu'
  KWR_ID = find_by(name: KWR_NAME)&.id || ActiveRecord::FixtureSet.identify(:keiwaryu)

  has_many :graduations, -> { order(:held_on) }, through: :groups
  has_many :groups, dependent: :destroy
  has_many :ranks, -> { order :position }

  validates :name, :family, presence: true
  validates :name, :family, uniqueness: true

  scope :kwr, -> { where(name: KWR_NAME) }

  def kwr?
    name == KWR_NAME
  end
end
