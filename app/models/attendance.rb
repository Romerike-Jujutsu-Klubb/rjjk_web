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
      [Status::WILL_ATTEND, 'Kommer!', 'icon-thumbs-up', 'btn-success'],
      [Status::HOLIDAY, 'Bortreist', 'icon-hand-right', 'btn-warning'],
      [Status::SICK, 'Syk', 'icon-plus', 'btn-danger'],
      [Status::ABSENT, 'Annet', 'icon-thumbs-down', 'btn-info'],
  ]

  ABSENT_STATES = [Status::HOLIDAY, Status::SICK, Status::ABSENT]

  scope :by_group_id, lambda { |group_id| includes(:practice => :group_schedule).where('group_schedules.group_id = ?', group_id)}
  scope :last_months, lambda { |count| limit = count.months.ago; where('(year = ? AND week >= ?) OR year > ?', limit.year, limit.to_date.cweek, limit.year) }
  scope :on_date, lambda { |date| where('year = ? AND week = ?', date.year, date.cweek) }

  belongs_to :member
  belongs_to :practice

  accepts_nested_attributes_for :practice

  validates_presence_of :member_id, :status
  validates_uniqueness_of :member_id, :scope => :practice_id

  validate :on => :update do
    errors.add(:status, 'kan ikke endres for treningen du var på.') if status_was == Status::ATTENDED && status == Status::WILL_ATTEND
  end

  def group_schedule
    practice.group_schedule
  end

  def date
    practice.date
  end

  #def self.find_member_count_for_month(group, year, month)
  #  find(:all, :conditions => ['group_schedule_id IN ? AND year = ?', group.group_schedules.map{|gs| gs.id}, year, month])
  #end

end
