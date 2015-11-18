require 'test_helper'

class SurveyAnswerFeatureTest < ActionDispatch::IntegrationTest
  def test_show_form
    id = survey_requests(:sent).id
    visit_with_login "/svar/#{id}", user: :lars
    first_select = find('#survey_request_survey_answers_attributes_0_answer', visible: false)
    assert_equal 'Velg et svar eller &quot;Annet&quot;', first_select['data-placeholder']
    second_select = find('#survey_request_survey_answers_attributes_1_answer', visible: false)
    assert_equal 'Velg et svar eller &quot;Annet&quot;', second_select['data-placeholder']
    screenshot('surveys/answer_form')
  end
end
