# frozen_string_literal: true

class MartialArt < ApplicationRecord
  KWR_NAME = 'Kei Wa Ryu'
  KWR = where(name: KWR_NAME)
      .first_or_create!(id: ActiveRecord::FixtureSet.identify(:keiwaryu), family: 'Jujutsu')

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
