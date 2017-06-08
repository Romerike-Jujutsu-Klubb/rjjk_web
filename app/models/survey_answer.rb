# frozen_string_literal: true

class SurveyAnswer < ApplicationRecord
  belongs_to :survey_request
  belongs_to :survey_question

  before_validation { self.answer -= ['', 'annet'] if answer.is_a?(Array) }

  def answers
    [*YAML.safe_load(answer)].reject(&:blank?)
  rescue
    [answer]
  end
end
