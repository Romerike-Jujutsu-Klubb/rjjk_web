# frozen_string_literal: true

class Semester < ApplicationRecord
  has_many :group_semesters, dependent: :destroy

  validates :end_on, :start_on, presence: true

  validate do
    if start_on && end_on && start_on > end_on
      errors.add(:end_on, 'Du må avslutte semesteret etter at det er startet.')
    end
    if Semester.where('id <> ? AND (start_on BETWEEN ? AND ? OR end_on BETWEEN ? AND ?)',
        id, start_on, end_on, start_on, end_on).exists?
      errors.add(:start_on, 'Semestre får ikke overlappe.')
    end
    if Semester.where('id <> ? AND start_on <= ? AND end_on >= ?', id, start_on, start_on).exists?
      errors.add(:start_on, 'Du kan ikke starte et semester inni et annet semester.')
    end
    if Semester.where('id <> ? AND start_on <= ? AND end_on >= ?', id, end_on, end_on).exists?
      errors.add(:end_on, 'Du kan ikke avslutte et semester inni et annet semester.')
    end
  end

  def self.current
    find_by('? BETWEEN start_on AND end_on', Date.current)
  end

  def self.next
    where('start_on > ?', Date.current).order(:start_on).first
  end

  def graduations
    Graduation.where('held_on BETWEEN ? and ?', start_on, end_on)
  end

  def name
    start_month = ApplicationController.helpers.month_name(start_on.mon).capitalize
    end_month = ApplicationController.helpers.month_name(end_on.mon).capitalize
    "#{start_on.year}: #{start_month}→#{end_month}"
  end

  def current?
    (start_on..end_on).cover? Date.current
  end

  def future?
    start_on > Date.current
  end

  def past?
    end_on < Date.current
  end
end
