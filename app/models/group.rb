class Group < ActiveRecord::Base
  belongs_to :martial_art
  has_and_belongs_to_many :members, :conditions => 'left_on IS NULL OR left_on > DATE(CURRENT_TIMESTAMP)'
  has_many :group_schedules
  has_many :ranks, :order => :position

  def full_name
    "#{martial_art.name} #{name}"
  end

  def contains_age(age)
    return false if age.nil?
    age >= from_age && age <= to_age
  end

  def trainings_in_period(period)
    weeks = 0.8 * (period.last - period.first) / 7
    (weeks * group_schedules.size).round
  end

  def registered_trainings_in_period(period)
    return 0 if group_schedules.empty?
    Attendance.
        select('group_schedule_id, year, week').
        group('group_schedule_id, year, week').
        where(*['group_schedule_id IN (?) AND (year > ? OR (year = ? AND week >= ?)) AND (year < ? OR (year = ? AND week <= ?))', group_schedules.map(&:id), *([[period.first.year]*2, period.first.cweek, [period.last.year]*2, period.last.cweek]).flatten]).
        all.size
  end

end
