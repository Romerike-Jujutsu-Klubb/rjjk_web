class MartialArt < ActiveRecord::Base
  has_many :graduations, order: :held_on, through: :groups
  has_many :groups, dependent: :destroy
  has_many :ranks, order: :position

  validates_presence_of :name, :family
  validates_uniqueness_of :name, :family

  scope :kwr, where(name: 'Kei Wa Ryu')

  def kwr?
    name == 'Kei Wa Ryu'
  end
end
