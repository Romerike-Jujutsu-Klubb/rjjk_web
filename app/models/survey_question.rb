# frozen_string_literal: true

class SurveyQuestion < ActiveRecord::Base
  acts_as_list

  belongs_to :survey
  has_many :survey_answers, dependent: :destroy
end
