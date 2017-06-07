# frozen_string_literal: true

class Graduation < ApplicationRecord
  belongs_to :group
  has_many :censors, dependent: :destroy
  has_many :graduates, dependent: :destroy

  validates :group, :group_id, :held_on, presence: true
  validates :group_notification, inclusion: { in: [true, false], message: 'må velges' }
  validates :held_on, uniqueness: { scope: :group_id }

  scope :not, ->(scope) { where(scope.where_values.reduce(:and).not) }

  scope :for_edit, -> do
    includes(
        censors: { member: { graduates: { rank: :martial_art } } },
        graduates: {
            graduation: {
                group: {
                    martial_art: { ranks: [{ group: %i(martial_art ranks) }, :martial_art] },
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
            rank: [{ group: %i(group_schedules ranks) }, :martial_art],
        },
        group: { members: :nkf_member }
    )
  end
  scope :censors_confirmed,
      ->(date) { where(<<~SQL, date) }
        NOT EXISTS (
          SELECT confirmed_at
          FROM censors WHERE graduation_id = graduations.id
            AND confirmed_at <= ?
        )
      SQL
  scope :has_examiners,
      -> { where(<<~SQL, true: true, false: false) }
        EXISTS (
          SELECT id
          FROM censors WHERE graduation_id = graduations.id
            AND examiner = :true AND declined = :false
        )
      SQL
  scope :ready,
      ->(date) { has_examiners.where(<<~SQL, date: date, true: true, false: false) }
        NOT EXISTS (
          SELECT locked_at
          FROM censors WHERE graduation_id = graduations.id
            AND (locked_at IS NULL OR locked_at > :date)
            AND examiner = :true AND declined = :false
        )
      SQL
  scope :approved,
      ->(date) { where(<<~SQL, date, false) }
        NOT EXISTS (
          SELECT approved_grades_at
          FROM censors WHERE graduation_id = graduations.id
            AND (approved_grades_at IS NULL OR approved_grades_at > ?)
            AND (declined IS NULL OR declined = ?)
        )
      SQL
  scope :upcoming, -> { where 'held_on >= ?', Date.current }

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
    group.try(:martial_art) || MartialArt.find_by(name: 'Kei Wa Ryu')
  end

  def description
    name
  end

  def passed?
    (held_on&.< Date.current)
  end

  def approved?
    non_declined_censors = censors.reject(&:declined?)
    passed? && non_declined_censors.any? && non_declined_censors.all?(&:approved?)
  end
end
