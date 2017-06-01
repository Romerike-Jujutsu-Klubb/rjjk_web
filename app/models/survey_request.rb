# frozen_string_literal: true

class SurveyRequest < ApplicationRecord
  belongs_to :member
  belongs_to :survey
  has_many :survey_answers, dependent: :destroy

  scope :pending, -> { where 'sent_at IS NOT NULL AND completed_at IS NULL' }
  scope :completed, -> { where.not completed_at: nil }

  accepts_nested_attributes_for :survey_answers
end
