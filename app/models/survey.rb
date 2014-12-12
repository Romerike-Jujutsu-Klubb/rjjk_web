class Survey < ActiveRecord::Base
  acts_as_list

  has_many :survey_questions, dependent: :destroy
  has_many :survey_requests, dependent: :destroy
  has_many :members, through: :survey_requests

  def included_members
    Member.active.where('birthdate IS NOT NULL AND birthdate <= ?',
        Member::JUNIOR_AGE_LIMIT.years.ago)
  end

  def pending_members
    survey_requests.pending.map(&:member)
  end

  def completed_members
    survey_requests.completed.map(&:member)
  end
end
