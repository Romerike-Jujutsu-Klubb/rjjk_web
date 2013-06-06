class Graduation < ActiveRecord::Base
  belongs_to :group
  has_many :censors
  has_many :graduates

  validates_presence_of :group, :held_on

  def start_at
    held_on.at(group_schedule.try(:start_at) || TimeOfDay.new(17, 45))
  end

  def end_at
    held_on.at(group_schedule.try(:end_at) || TimeOfDay.new(20, 30))
  end

  def ingress
    nil
  end

  def body
    nil
  end

  def name
    "Gradering #{group.name}"
  end

    def group_schedule
    group.group_schedules.find { |gs| gs.weekday == held_on.cwday }
  end

  def martial_art
    group.try(:martial_art) || MartialArt.find_by_name('Kei Wa Ryu')
  end

end
