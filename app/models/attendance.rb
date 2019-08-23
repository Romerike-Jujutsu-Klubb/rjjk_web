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

  STATES = [
    [Status::WILL_ATTEND, 'Kommer!', 'thumbs-up', 'success'],
    [Status::INSTRUCTOR, 'Instruere', 'thumbs-up', 'success'],
    [Status::HOLIDAY, 'Bortreist', 'hand-point-right', 'warning'],
    [Status::SICK, 'Syk', 'plus', 'danger'],
    [Status::ABSENT, 'Annet', 'thumbs-down', 'info'],
  ].freeze

  CURRENT_STATES = [
    [Status::WILL_ATTEND, 'Kommer!', 'thumbs-up', 'success'],
    [Status::ATTENDED, 'Trener!', 'thumbs-up', 'success'],
    [Status::INSTRUCTOR, 'Instruere', 'thumbs-up', 'success'],
    [Status::HOLIDAY, 'Bortreist', 'hand-point-right', 'warning'],
    [Status::SICK, 'Syk', 'plus', 'danger'],
    [Status::ABSENT, 'Annet', 'thumbs-down', 'info'],
  ].freeze

  PAST_STATES = [
    [Status::WILL_ATTEND, 'Ubekreftet', 'question', 'warning'],
    [Status::ATTENDED, 'Trente!', 'thumbs-up', 'success'],
    [Status::INSTRUCTOR, 'Instruerte!', 'thumbs-up', 'success'],
    [Status::HOLIDAY, 'Bortreist', 'hand-point-right', 'warning'],
    [Status::SICK, 'Syk', 'plus', 'danger'],
    [Status::ABSENT, 'Annet', 'thumbs-down', 'info'],
  ].freeze

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
        .where('group_schedules.group_id = ?', group_id)
  }
  scope :from_date, ->(limit) {
    from_date = limit.to_date
    includes(practice: :group_schedule).references(:group_schedules)
        .where('practices.year > :year OR (practices.year = :year AND practices.week > :week) OR ' \
        '(practices.year = :year AND practices.week = :week AND group_schedules.weekday >= :wday)',
            year: from_date.cwyear, week: from_date.cweek, wday: from_date.cwday)
  }
  scope :on_date, ->(date) { where('year = ? AND week = ?', date.year, date.cweek) }
  scope :present, -> { where status: PRESENCE_STATES }
  scope :to_date, ->(limit) {
    to_date = limit.to_date
    includes(practice: :group_schedule).references(:group_schedules)
        .where('practices.year < :year OR (practices.year = :year AND practices.week < :week) OR ' \
            '(practices.year = :year AND practices.week = :week AND group_schedules.weekday <= :wday)',
            year: to_date.cwyear, week: to_date.cweek, wday: to_date.cwday)
  }

  belongs_to :member
  belongs_to :practice
  has_one :group_schedule, through: :practice

  accepts_nested_attributes_for :practice

  validates :member_id, :status, presence: true
  validates :member_id, uniqueness: { scope: :practice_id }

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
    "#{member} #{practice} (#{status})"
  end

  def status_label
    (Time.current < practice.start_at ? STATES : PAST_STATES).find { |s| s[0] == status }&.at(1) || status
  end
end
