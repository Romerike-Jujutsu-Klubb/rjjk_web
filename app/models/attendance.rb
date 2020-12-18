# frozen_string_literal: true

class Attendance < ApplicationRecord
  module Status
    ABSENT = 'F'
    ASSISTANT = 'H'
    ATTENDED = 'X'
    HOLIDAY = 'B'
    INSTRUCTOR = 'I'
    PRESENT = 'T'
    SICK = 'S'
    WILL_ATTEND = 'P'
  end

  # Listed in display order
  STATES = {
    Status::WILL_ATTEND => %w[Kommer! thumbs-up success],
    Status::INSTRUCTOR => %w[Instruere thumbs-up success],
    Status::HOLIDAY => %w[Bortreist hand-point-right warning],
    Status::SICK => %w[Pandemi plus danger],
    Status::ABSENT => %w[Forhindret thumbs-down info],
  }.freeze

  # Listed in display order
  CURRENT_STATES = {
    Status::WILL_ATTEND => %w[Kommer! thumbs-up success],
    Status::ATTENDED => %w[Trener! thumbs-up success],
    Status::INSTRUCTOR => %w[Instruere thumbs-up success],
    Status::HOLIDAY => %w[Bortreist hand-point-right warning],
    Status::SICK => %w[Pandemi plus danger],
    Status::ABSENT => %w[Forhindret thumbs-down info],
  }.freeze

  PAST_STATES = {
    Status::ATTENDED => %w[Trente! thumbs-up success],
    Status::INSTRUCTOR => %w[Instruerte! thumbs-up success],
    Status::HOLIDAY => %w[Bortreist hand-point-right warning],
    Status::SICK => %w[Pandemi plus danger],
    Status::ABSENT => %w[Forhindret thumbs-down info],
    Status::WILL_ATTEND => %w[Ubekreftet question warning],
  }.freeze

  PRESENT_STATES = [Status::ASSISTANT, Status::ATTENDED, Status::INSTRUCTOR, Status::PRESENT].freeze
  ABSENT_STATES = [Status::HOLIDAY, Status::SICK, Status::ABSENT].freeze
  PRESENCE_STATES = [*PRESENT_STATES, Status::WILL_ATTEND].freeze

  scope :after, ->(limit) {
    from_date = limit.to_date
    includes(practice: :group_schedule).references(:group_schedules)
        .where('practices.year > :year OR (practices.year = :year AND practices.week > :week) OR ' \
        '(practices.year = :year AND practices.week = :week AND group_schedules.weekday > :wday)',
            year: from_date.cwyear, week: from_date.cweek, wday: from_date.cwday)
  }
  scope :before, ->(limit) {
    to_date = limit.to_date
    includes(practice: :group_schedule).references(:group_schedules)
        .where('practices.year < :year OR (practices.year = :year AND practices.week < :week) OR ' \
            '(practices.year = :year AND practices.week = :week AND group_schedules.weekday < :wday)',
            year: to_date.cwyear, week: to_date.cweek, wday: to_date.cwday)
  }
  scope :by_group_id, ->(group_id) {
    includes(practice: :group_schedule).references(:group_schedules)
        .where(group_schedules: { group_id: group_id })
  }
  scope :from_date, ->(limit) {
    from_date = limit.to_date
    left_outer_joins(practice: :group_schedule).references(:group_schedules, :practices)
        .where('practices.year > :year OR (practices.year = :year AND practices.week > :week) OR ' \
        '(practices.year = :year AND practices.week = :week AND group_schedules.weekday >= :wday)',
            year: from_date.cwyear, week: from_date.cweek, wday: from_date.cwday)
  }
  scope :on_date, ->(date) { where('year = ? AND week = ?', date.year, date.cweek) }
  scope :present, -> { where status: PRESENCE_STATES }
  scope :to_date, ->(limit) {
    to_date = limit.to_date
    left_outer_joins(practice: :group_schedule).references(:group_schedules, :practices)
        .where('practices.year < :year OR (practices.year = :year AND practices.week < :week) OR ' \
            '(practices.year = :year AND practices.week = :week AND group_schedules.weekday <= :wday)',
            year: to_date.cwyear, week: to_date.cweek, wday: to_date.cwday)
  }

  belongs_to :user
  belongs_to :practice
  has_one :group_schedule, through: :practice

  accepts_nested_attributes_for :practice

  validates :rated_at, presence: true, if: :rating
  validates :rating, presence: true, if: :rated_at
  validates :status, presence: true
  validates :user_id, presence: true, uniqueness: { scope: :practice_id }

  validate on: :update do
    if status_was == Status::ATTENDED && status == Status::WILL_ATTEND
      errors.add(:status, 'kan ikke endres for treningen du var på.')
    end
  end

  delegate :date, to: :practice

  def present?
    PRESENCE_STATES.include?(status)
  end

  def to_s
    "#{user} #{practice} (#{status})"
  end

  def status_label
    (Time.current < practice.start_at ? STATES : PAST_STATES)[status]&.at(0) || status
  end
end
