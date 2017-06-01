# frozen_string_literal: true

class SurveyQuestion < ApplicationRecord
  acts_as_list

  belongs_to :survey
  has_many :survey_answers, dependent: :destroy
end
