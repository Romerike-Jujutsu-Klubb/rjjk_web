# frozen_string_literal: true
class MartialArt < ActiveRecord::Base
  has_many :graduations, -> { order(:held_on) }, through: :groups
  has_many :groups, dependent: :destroy
  has_many :ranks, -> { order :position }

  validates :name, :family, presence: true
  validates :name, :family, uniqueness: true

  scope :kwr, -> { where(name: 'Kei Wa Ryu') }

  def kwr?
    name == 'Kei Wa Ryu'
  end
end
