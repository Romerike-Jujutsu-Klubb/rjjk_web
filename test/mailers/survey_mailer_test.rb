require 'test_helper'

class SurveyMailerTest < ActionMailer::TestCase
  test 'survey' do
    mail = SurveyMailer.survey(survey_requests(:unsent))
    assert_equal 'First survey', mail.subject
    assert_equal [], mail.to
    assert_equal ['test@jujutsu.no'], mail.from
  end

  test 'reminder' do
    mail = SurveyMailer.reminder(survey_requests(:sent))
    assert_equal 'First survey', mail.subject
    assert_equal ['lars@example.com'], mail.to
    assert_equal ['test@jujutsu.no'], mail.from
    assert_match 'First survey', mail.body.encoded
  end
end
