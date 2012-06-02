class Graduate < ActiveRecord::Base
  belongs_to :graduation
  belongs_to :member
  belongs_to :rank

  validates_uniqueness_of :member_id, :scope => :graduation_id
  validates_uniqueness_of :member_id, :scope => [:passed, :rank_id], :if => :passed

  def training_start_date
    member.current_graduate(graduation.martial_art, graduation.held_on - 1).try(:graduation).try(:held_on) || member.joined_on
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
    member.attendances.select { |a| training_period.include? a.date }.size
  end

  def registered_trainings
    rank.group.registered_trainings_in_period(training_period)
  end

  def registration_percentage
    return 1 if planned_trainings == 0
    registered_trainings.to_f / planned_trainings
  end

  def estimated_attendances
    registered_attendances = training_attendances
    return registered_attendances if planned_trainings == 0
    registered_trainings = registrered_trainings
    return registered_attendances if registered_trainings
    registered_attendances / registration_percentage
  end

  def minimum_attendances
    ([rank.minimum_attendances * registration_percentage, rank.minimum_age <= 12 ? registered_trainings * 0.5 : nil].compact.min).round
  end
end
