require 'test_helper'

class SurveyAnswerFeatureTest < ActionDispatch::IntegrationTest
  def test_show_form
    id = survey_requests(:sent).id
    visit_with_login "/svar/#{id}", user: :lars
    puts body
    puts all('a').map{|e| e[:id]}
    puts all('input').map{|e| e[:id]}
    puts all('select').map(&:id).to_s
    assert_equal 'Velg et svar eller "Annet"',
        find('#survey_request_survey_answers_attributes_0_answer').value,
        all('select').map(&:id).to_s
    screenshot('surveys/answer_form')
  end
end
