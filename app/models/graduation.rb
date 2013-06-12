class Graduation < ActiveRecord::Base
  belongs_to :group
  has_many :censors
  has_many :graduates
  belongs_to :event

  validates_presence_of :event, :group, :held_on

  def default_start_at
    held_on.try(:at, group_schedule.try(:start_at) || TimeOfDay.new(17, 45))
  end

  def default_end_at
    held_on.try(:at, group_schedule.try(:end_at) || TimeOfDay.new(20, 30))
  end

  def default_name
    "Gradering #{group.name}"
  end

  def group_schedule
    group.group_schedules.find { |gs| gs.weekday == held_on.try(:cwday) }
  end

  def martial_art
    group.try(:martial_art) || MartialArt.find_by_name('Kei Wa Ryu')
  end

end
