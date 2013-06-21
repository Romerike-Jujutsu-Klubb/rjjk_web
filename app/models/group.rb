class Group < ActiveRecord::Base
  scope :active, -> date { where('closed_on IS NULL OR closed_on >= ?', date) }

  belongs_to :martial_art
  has_and_belongs_to_many :members, :conditions => 'left_on IS NULL OR left_on > DATE(CURRENT_TIMESTAMP)'
  has_many :group_schedules
  has_many :ranks, :order => :position
  has_many :graduations, :order => :held_on
  has_one :current_semester, :class_name => :GroupSemester,
          :include => :semester,
          :conditions => 'CURRENT_DATE BETWEEN semesters.start_on AND semesters.end_on'
  has_one :next_semester, :class_name => :GroupSemester,
          :include => :semester,
          :conditions => 'semesters.start_on > CURRENT_DATE',
          :order => 'semesters.start_on'

  validates_presence_of :from_age, :martial_art, :name, :to_age

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

  def active?(date = Date.today)
    closed_on.nil? || closed_on >= date
  end

  def update_prices
    contracts = NkfMember.where(:kontraktstype => contract).all
    return if contracts.empty?
    self.monthly_price = contracts.map(&:kontraktsbelop).group_by { |x| x }.group_by { |k, v| v.size }.sort.last.last.map(&:first).first
    self.yearly_price = contracts.map(&:kont_belop).group_by { |x| x }.group_by { |k, v| v.size }.sort.last.last.map(&:first).first
  end

end
