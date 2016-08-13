# FIXME(uwe): Split into AgeGroup and TrainingGroup
class Group < ActiveRecord::Base
  scope :active, -> date = nil { date ? where('closed_on IS NULL OR closed_on >= ?', date) : where('closed_on IS NULL') }
  scope :inactive, -> date { where('closed_on IS NOT NULL AND closed_on < ?', date) }

  belongs_to :martial_art
  has_one :current_semester,
      -> { references(:semesters).includes(:semester).where('CURRENT_DATE BETWEEN semesters.start_on AND semesters.end_on') },
      class_name: :GroupSemester
  has_many :graduations, -> { order(:held_on) }, :dependent => :destroy
  has_many :group_schedules, :dependent => :destroy
  has_many :group_semesters, :dependent => :destroy
  has_one :next_graduation,
      -> { where('graduations.held_on >= ?', Date.today).order('graduations.held_on') },
      :class_name => :Graduation
  has_one :next_semester,
      -> { includes(:semester).where('semesters.start_on > CURRENT_DATE').order('semesters.start_on') },
          :class_name => :GroupSemester
  has_many :ranks, -> { order(:position) }, :dependent => :destroy
  # FIXME(uwe): Add model GroupMembership and change to has_many through:
  has_and_belongs_to_many :members, conditions: 'left_on IS NULL OR left_on > DATE(CURRENT_TIMESTAMP)'

  accepts_nested_attributes_for :current_semester
  accepts_nested_attributes_for :next_semester

  before_validation { |r| r.color = nil if r.color.blank? }

  validates_presence_of :from_age, :martial_art, :name, :to_age

  def full_name
    "#{"#{martial_art.name} " if martial_art.name != 'Kei Wa Ryu'}#{name}"
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
    Practice.
        where(*["status = 'X' AND group_schedule_id IN (?) AND (year > ? OR (year = ? AND week >= ?)) AND (year < ? OR (year = ? AND week <= ?))",
        group_schedules.map(&:id), *([[period.first.year] * 2, period.first.cweek, [period.last.year] * 2, period.last.cweek]).flatten]).
        all.size
  end

  def active?(date = Date.today)
    closed_on.nil? || closed_on >= date
  end

  def update_prices
    contracts = NkfMember.where(:kontraktstype => contract).to_a
    return if contracts.empty?
    self.monthly_price = contracts.map(&:kontraktsbelop).group_by { |x| x }.group_by { |k, v| v.size }.sort.last.last.map(&:first).first
    self.yearly_price = contracts.map(&:kont_belop).group_by { |x| x }.group_by { |k, v| v.size }.sort.last.last.map(&:first).first
  end

  def next_schedule
    group_schedules.sort_by { |gs| gs.next_practice.date }.first
  end

  def next_practice
    next_schedule.next_practice
  end

  def instructors
    group_schedules.map(&:group_instructors).flatten.select(&:active?).
        map(&:member).uniq.
        sort_by { |m| -(m.current_rank.try(:position) || -99) }
  end

  def trials
    NkfMemberTrial.for_group(self).
        includes(:trial_attendances => { :practice => :group_schedule }).
        order('fornavn, etternavn').
        to_a
  end

  def waiting_list
    return [] unless target_size
    trial_list = trials.sort_by { |t| [-t.trial_attendances.size, t.reg_dato] }
    active_size = members.select(&:active?).size
    active_trial_count = (target_size - active_size)
    trial_list[active_trial_count..-1] || []
  end

end
