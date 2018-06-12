# frozen_string_literal: true

class Graduate < ApplicationRecord
  belongs_to :graduation
  belongs_to :member
  belongs_to :rank

  validates :graduation, :graduation_id, :member, :member_id, :rank, :rank_id, presence: true
  validates :member_id, uniqueness: { scope: :graduation_id }
  validates :member_id, uniqueness: { scope: %i[passed rank_id], if: :passed,
                                      message: 'har allerede bestått denne graden.' }
  validates :passed, inclusion: { in: [true, false], if: ->(g) { g.graduation.approved? } }

  before_destroy do
    if invitation_sent_at
      errors.add :base, 'Kandidaten er allerede invitert.'
      throw :abort
    end
  end

  def training_start_date
    member.current_graduate(graduation.group.martial_art, graduation.held_on - 1).try(:graduation)
        .try(:held_on).try(:+, 1) ||
        [member.joined_on, member.attendances.includes(:practice)
            .where('practices.year < :year OR (practices.year = :year AND practices.week <= :week)',
                year: member.joined_on.cwyear, week: member.joined_on.cweek)
            .order('practices.year, practices.week').first&.date].compact.min
  end

  def training_duration
    ((graduation.held_on - training_start_date) / 30.0).round
  end

  def training_period
    training_start_date..graduation.held_on
  end

  def planned_trainings
    rank.group.trainings_in_period(training_period)
  end

  def training_attendances
    ats = if member.attendances.loaded?
            member.attendances.select { |a| training_period.include? a.date }
          else
            member.attendances.includes(:practice).after(training_start_date).before(graduation.held_on)
          end
    ats.size
  end

  def registered_trainings
    rank.group.registered_trainings_in_period(training_period)
  end

  def registration_percentage
    planned_trainings.zero? ? 1 : registered_trainings.to_f / planned_trainings
  end

  def estimated_attendances
    registered_attendances = training_attendances
    return registered_attendances if planned_trainings.zero?
    registered_trainings = registrered_trainings
    return registered_attendances if registered_trainings
    registered_attendances / registration_percentage
  end

  def expected_attendances
    ats = [rank.expected_attendances]
    if rank.minimum_age <= 12 && (trainings = registered_trainings) > 0 &&
          (training_days = Date.current - training_start_date) > 0
      semester_days = graduation.held_on - training_start_date
      time_factor = semester_days.to_f / training_days
      ats << (trainings * time_factor)
    end
    ats.min.round
  end

  def minimum_attendances
    (expected_attendances / 2.0).ceil
  end

  def current_rank_age
    member.current_rank_age(graduation.group.martial_art, graduation.held_on)
  end
end
