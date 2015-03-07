# encoding: utf-8
class Attendance < ActiveRecord::Base
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
      [Status::HOLIDAY, 'Bortreist', 'hand-right', 'warning'],
      [Status::SICK, 'Syk', 'plus', 'danger'],
      [Status::ABSENT, 'Annet', 'thumbs-down', 'info'],
  ]

  PAST_STATES = [
      [Status::ATTENDED, 'Var der!', 'thumbs-up', 'success'],
      [Status::HOLIDAY, 'Bortreist', 'hand-right', 'warning'],
      [Status::SICK, 'Syk', 'plus', 'danger'],
      [Status::ABSENT, 'Annet', 'thumbs-down', 'info'],
  ]

  PRESENT_STATES = [Status::ASSISTANT, Status::ATTENDED, Status::INSTRUCTOR, Status::PRESENT]
  ABSENT_STATES = [Status::HOLIDAY, Status::SICK, Status::ABSENT]
  PRESENCE_STATES = [*PRESENT_STATES, Status::WILL_ATTEND]

  scope :by_group_id, -> group_id { includes(practice: :group_schedule).references(:group_schedules).where('group_schedules.group_id = ?', group_id) }
  scope :last_months, -> count { limit = count.months.ago; where('(year = ? AND week >= ?) OR year > ?', limit.year, limit.to_date.cweek, limit.year) }
  scope :on_date, -> date { where('year = ? AND week = ?', date.year, date.cweek) }
  scope :after_date, -> date { includes(practice: :group_schedule).references(:group_schedules).where('year > ? OR (year = ? AND week > ?) OR (year = ? AND week = ? AND group_schedules.weekday > ?)', date.year, date.year, date.cweek, date.year, date.cweek, date.cwday) }
  scope :until_date, -> date { includes(practice: :group_schedule).references(:group_schedules).where('year < ? OR (year = ? AND week < ?) OR (year = ? AND week = ? AND group_schedules.weekday <= ?)', date.year, date.year, date.cweek, date.year, date.cweek, date.cwday) }

  belongs_to :member
  belongs_to :practice

  accepts_nested_attributes_for :practice

  validates_presence_of :member_id, :status
  validates_uniqueness_of :member_id, :scope => :practice_id

  validate on: :update do
    errors.add(:status, 'kan ikke endres for treningen du var på.') if status_was == Status::ATTENDED && status == Status::WILL_ATTEND
  end

  def group_schedule
    practice.group_schedule
  end

  def date
    practice.date
  end

  def present?
    PRESENCE_STATES.include?(status)
  end

  #def self.find_member_count_for_month(group, year, month)
  #  all.where('group_schedule_id IN ? AND year = ?', group.group_schedules.map{|gs| gs.id}, year, month)
  #end

end
