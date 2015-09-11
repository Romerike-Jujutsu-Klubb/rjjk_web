class Graduation < ActiveRecord::Base
  belongs_to :group
  has_many :censors, dependent: :destroy
  has_many :graduates, dependent: :destroy

  validates_presence_of :group, :held_on

  validates_uniqueness_of :held_on, scope: :group_id

  def start_at
    held_on.try(:at, group_schedule.try(:start_at) || TimeOfDay.new(17, 45))
  end

  def end_at
    held_on.try(:at, group_schedule.try(:end_at) || TimeOfDay.new(20, 30))
  end

  def name
    "Gradering #{group.name}"
  end

  def body
    true
  end

  def size
    graduates.size
  end

  def group_schedule
    group.group_schedules.find { |gs| gs.weekday == held_on.try(:cwday) }
  end

  def martial_art
    group.try(:martial_art) || MartialArt.find_by_name('Kei Wa Ryu')
  end

  def description
    name
  end
end
