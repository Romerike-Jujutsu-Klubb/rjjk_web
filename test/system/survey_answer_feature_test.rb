# frozen_string_literal: true

require 'application_system_test_case'

class SurveyAnswerFeatureTest < ApplicationSystemTestCase
  def test_show_form
    id = survey_requests(:sent).id
    visit_with_login "/svar/#{id}", user: :lars

    first_select = find('#survey_request_survey_answers_attributes_0_answer', visible: false)
    assert_equal 'Velg et svar eller "Annet"', first_select['data-placeholder']

    second_select = find('#survey_request_survey_answers_attributes_1_answer', visible: false)
    assert_equal 'Velg et svar eller "Annet"', second_select['data-placeholder']
    screenshot('surveys/answer_form')
  end
end
