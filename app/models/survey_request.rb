class SurveyRequest < ActiveRecord::Base
  belongs_to :member
  belongs_to :survey
  has_many :survey_answers, dependent: :destroy
  has_many :survey_questions, through: :survey_answers

  scope :pending, ->{where completed_at: nil}
  scope :completed, ->{where.not completed_at: nil}

  accepts_nested_attributes_for :survey_answers
end
