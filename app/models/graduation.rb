# frozen_string_literal: true
class Graduation < ActiveRecord::Base
  belongs_to :group
  has_many :censors, dependent: :destroy
  has_many :graduates, dependent: :destroy

  validates :group, :group_id, :held_on, presence: true
  validates :group_notification, inclusion: { in: [true, false], message: 'må velges' }
  validates :held_on, uniqueness: { scope: :group_id }

  scope :for_edit, -> do
    includes(
        censors: { member: { graduates: { rank: :martial_art } } },
        graduates: {
            graduation: {
                group: {
                    martial_art: { ranks: [{ group: [:martial_art, :ranks] }, :martial_art] },
                },
            },
            member: [
                {
                    attendances: {
                        practice: :group_schedule,
                    },
                    graduates: [
                        {
                            graduation: :group,
                        },
                        :rank,
                    ],
                },
                :nkf_member,
            ],
            rank: [{ group: [:group_schedules, :ranks] }, :martial_art],
        },
        group: { members: :nkf_member }
    )
  end
  scope :locked,
      ->(date) { where(<<~SQL, date) }
        NOT EXISTS (
          SELECT locked_at
          FROM censors WHERE graduation_id = graduations.id
            AND (locked_at IS NULL OR locked_at <= ?)
        )
      SQL
  scope :approved,
      ->(date) { where(<<~SQL, date) }
        NOT EXISTS (
          SELECT approved_grades_at
          FROM censors WHERE graduation_id = graduations.id
            AND (approved_grades_at IS NULL OR approved_grades_at <= ?)
        )
      SQL

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
    held_on && censors.any? && held_on < Date.current && censors.all?(&:approved?)
  end
end
