class Semester < ActiveRecord::Base
  has_many :group_semesters, dependent: :destroy

  validates_presence_of :end_on, :start_on

  validate do
    if start_on && end_on && start_on > end_on
      errors.add(:end_on, 'Du må avslutte semesteret etter at det er startet.')
    end
    if Semester.where('id <> ? AND (start_on BETWEEN ? AND ? OR end_on BETWEEN ? AND ?)', id, start_on, end_on, start_on, end_on).exists?
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
    where('CURRENT_DATE BETWEEN start_on AND end_on').first
  end

  def self.next
    where('start_on > CURRENT_DATE').order(:start_on).first
  end

  def graduations
    Graduation.where('held_on BETWEEN ? and ?', start_on, end_on)
  end

  def name
    "#{start_on.year}: #{start_on.strftime('%m-%d')}→#{end_on.strftime('%m-%d')}"
  end

  def current?
    (start_on..end_on).cover? Date.today
  end

  def future?
    start_on > Date.today
  end

  def past?
    end_on < Date.today
  end
end
