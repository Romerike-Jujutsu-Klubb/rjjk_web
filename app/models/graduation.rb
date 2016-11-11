# frozen_string_literal: true
class Graduation < ActiveRecord::Base
  belongs_to :group
  has_many :censors, dependent: :destroy
  has_many :graduates, dependent: :destroy

  validates :group, :held_on, presence: true

  validates :held_on, uniqueness: { scope: :group_id }

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

  delegate :size, to: :graduates

  def group_schedule
    group.group_schedules.find { |gs| gs.weekday == held_on.try(:cwday) }
  end

  def martial_art
    group.try(:martial_art) || MartialArt.find_by_name('Kei Wa Ryu')
  end

  def description
    name
  end

  def approved?
    censors.any? && held_on < Date.current && censors.all?(&:approved?)
  end
end
