# frozen_string_literal: true

# FIXME(uwe): Split into AgeGroup and TrainingGroup
class Group < ApplicationRecord
  belongs_to :martial_art

  has_one :current_semester,
      -> {
        joins(:semester).where('? BETWEEN semesters.start_on AND semesters.end_on', Date.current)
      },
      class_name: :GroupSemester
  has_one :next_graduation,
      -> { where('graduations.held_on >= ?', Date.current).order('graduations.held_on') },
      class_name: :Graduation
  has_one :next_semester, -> do
    includes(:semester).where('semesters.start_on > ?', Date.current).order('semesters.start_on')
  end, class_name: :GroupSemester

  has_many :graduations, -> { order(:held_on) }, dependent: :destroy
  has_many :group_memberships, dependent: :destroy
  has_many :group_schedules, dependent: :destroy
  has_many :group_semesters, dependent: :destroy
  has_many :ranks, -> { order(:position) }, dependent: :destroy

  has_many :members, through: :group_memberships
  has_many :practices, through: :group_schedules

  accepts_nested_attributes_for :current_semester
  accepts_nested_attributes_for :next_semester

  scope :active, ->(date = nil) do
    date ? where('closed_on IS NULL OR closed_on >= ?', date) : where('closed_on IS NULL')
  end
  scope :inactive, ->(date) { where('closed_on IS NOT NULL AND closed_on < ?', date) }

  before_validation { |r| r.color = nil if r.color.blank? }

  validates :from_age, :martial_art, :name, :to_age, presence: true
  validates :contract, length: { maximum: 32 }

  def full_name
    "#{"#{martial_art.name} " if martial_art_id != MartialArt::KWR_ID}#{name}"
  end

  def contains_age(age)
    return false if age.nil?

    age >= from_age && age <= to_age
  end

  def trainings_in_period(period)
    weeks = 0.8 * (period.last - period.first) / 7
    (weeks * [group_schedules.size, 2].min).round
  end

  def registered_trainings_in_period(period)
    return 0 if group_schedules.empty?

    Practice
        .where("status = 'X' AND group_schedule_id IN (?)", group_schedules.map(&:id))
        .where('year > ? OR (year = ? AND week >= ?)',
            *([period.first.year] * 2), period.first.cweek)
        .where('year < ? OR (year = ? AND week <= ?)',
            *([period.last.year] * 2), period.last.cweek)
        .all.size
  end

  def active?(date = Date.current)
    closed_on.nil? || closed_on >= date
  end

  def update_prices
    contracts = NkfMember.where(kontraktstype: contract).to_a
    return if contracts.empty?

    self.monthly_price = contracts.map(&:kontraktsbelop).group_by { |x| x }
        .group_by { |_k, v| v.size }.max.last.map(&:first).first
    self.yearly_price = contracts.map(&:kont_belop).group_by { |x| x }
        .group_by { |_k, v| v.size }.max.last.map(&:first).first
  end

  def next_schedule
    group_schedules.min_by { |gs| gs.next_practice.date }
  end

  delegate :next_practice, to: :next_schedule

  def instructors
    group_schedules.map(&:active_group_instructors).flatten.map(&:member)
        .sort_by(&:current_rank).reverse
  end

  def active_instructors(dates = [Date.current])
    instructors = []

    if (chief_instructor = current_semester&.chief_instructor)
      instructors << chief_instructor
    end
    group_instructors_query = GroupInstructor
        .includes(:group_schedule,
            member: [{ attendances: { practice: :group_schedule } }, :nkf_member])
        .where(group_schedules: { group_id: id })
    if instructors.any?
      group_instructors_query = group_instructors_query
          .where('group_instructors.member_id NOT IN (?)', instructors.map(&:id))
    end
    instructors += group_instructors_query.to_a.select { |gi| dates.any? { |d| gi.active?(d) } }
        .map(&:member).uniq
    instructors_query = Member.active(dates.first, dates.last)
        .includes({ attendances: { practice: :group_schedule },
                    graduates: %i[graduation rank] }, :groups, :nkf_member)
        .where(instructor: true)
    instructors_query = instructors_query.where('id NOT IN (?)', instructors.map(&:id)) if instructors.any?
    instructors += instructors_query
        .select { |m| m.groups.any? { |g| g.martial_art_id == martial_art_id } }
        .select do |m|
      m.attendances.any? do |a|
        ((dates.first - 92.days)..dates.last).cover?(a.date) &&
            a.group_schedule.group_id == id
      end
    end

    instructors.uniq.sort_by(&:current_rank).reverse
  end

  def trials
    NkfMemberTrial.for_group(self)
        .includes(trial_attendances: { practice: :group_schedule })
        .order('fornavn, etternavn')
        .to_a
  end

  def waiting_list
    return [] unless target_size

    trial_list = trials.sort_by { |t| [-t.trial_attendances.size, t.reg_dato] }
    active_size = members.select(&:active?).size
    active_trial_count = (target_size - active_size)
    trial_list[active_trial_count..-1] || []
  end

  def suggested_graduation_date(date = Date.current)
    group_schedule = group_schedules.min_by(&:weekday)
    return unless group_schedule

    second_week = Date.civil(date.year, date.mon >= 7 ? 12 : 6, 11).beginning_of_week
    second_week + group_schedule.weekday - 1
  end
end
