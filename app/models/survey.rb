# frozen_string_literal: true

class Survey < ApplicationRecord
  acts_as_list

  has_many :survey_questions, dependent: :destroy
  has_many :survey_requests, dependent: :destroy
  has_many :members, through: :survey_requests

  def included_members
    Member.active.includes(:user).references(:users)
        .where('users.birthdate IS NOT NULL AND birthdate <= ?', Member::JUNIOR_AGE_LIMIT.years.ago)
  end

  def pending_members
    survey_requests.pending.map(&:member)
  end

  def completed_members
    survey_requests.completed.map(&:member)
  end

  def ready_members
    included_members.order(:joined_on) - pending_members - completed_members
  end
end
