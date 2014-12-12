class SurveyAnswer < ActiveRecord::Base
  belongs_to :survey_request
  belongs_to :survey_question
end
