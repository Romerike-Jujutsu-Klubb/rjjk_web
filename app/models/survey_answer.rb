class SurveyAnswer < ActiveRecord::Base
  belongs_to :survey_request
  belongs_to :survey_question

  before_validation { self.answer-=['', 'annet'] if answer.is_a?(Array) }

  def answers
    [*YAML.load(answer)].reject(&:blank?) rescue [answer]
  end
end
