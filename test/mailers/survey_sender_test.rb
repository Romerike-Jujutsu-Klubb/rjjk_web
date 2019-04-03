# frozen_string_literal: true

require 'test_helper'

class SurveySenderTest < ActionMailer::TestCase
  def test_send_surveys
    assert_mail_stored do
      assert_no_difference 'SurveyRequest.count' do
        SurveySender.send_surveys
      end
    end

    mail = UserMessage.pending[0]
    assert_equal 'First survey', mail.subject
    assert_equal ['uwe@example.com'], mail.to
    assert_equal ['medlem@test.jujutsu.no'], mail.from
    assert_equal(
        { 'controller' => 'survey_requests', 'action' => 'answer_form', 'id' => 397_345_097 },
        mail.email_url
      )
    assert_equal TEST_TIME, mail.message_timestamp
    assert_match 'First header text', mail.body
    assert_match 'First question', mail.body
    assert_match 'Second question', mail.body
    assert_match 'What do you think of this survey?', mail.body
    assert_match %r{
          For\ å\ svare\ på\ spørsmålene,\ kan\ du\ følge\ denne\ linken:\s+
          <a\ href="https://example.com/svar/397345097">https://example.com/svar/397345097</a>
        }x,
        mail.body
    assert survey_requests(:unsent).sent_at

    assert_mail_stored initial: 1 do
      assert_difference 'SurveyRequest.count' do
        SurveySender.send_surveys
      end
    end

    mail = UserMessage.pending[1]
    assert_equal 'First survey', mail.subject
    assert_equal ['neuer@example.com', 'newbie@example.com'], mail.to
    assert_equal ['medlem@test.jujutsu.no'], mail.from
    assert_match 'First header text', mail.body
    assert_match 'First question', mail.body
    assert_match 'Second question', mail.body
    assert_match 'What do you think of this survey?', mail.body
    assert_match %r{
          For\ å\ svare\ på\ spørsmålene,\ kan\ du\ følge\ denne\ linken:\s+
          <a\ href="https://example.com/svar/98593450[89]">https://example.com/svar/98593450[89]</a>
        }x,
        mail.body

    assert_mail_stored initial: 2 do
      assert_no_difference 'SurveyRequest.count' do
        SurveySender.send_surveys
      end
    end

    mail = UserMessage.pending[2]
    assert_equal 'First survey', mail.subject
    assert_equal ['lars@example.com'], mail.to
    assert_equal ['medlem@test.jujutsu.no'], mail.from
    assert_match 'First header text', mail.body
    assert_match 'First question', mail.body
    assert_match 'Second question', mail.body
    assert_match 'What do you think of this survey?', mail.body
    assert_match %r{
          For\ å\ svare\ på\ spørsmålene,\ kan\ du\ følge\ denne\ linken:\s+
          <a\ href="https://example.com/svar/985934507">https://example.com/svar/985934507</a>
        }x,
        mail.body
    assert survey_requests(:sent).reminded_at
  end

  test 'do not send reminders to ex-members' do
    Member.all.each { |m| m.update! left_on: 7.days.ago }

    assert_mail_stored(0) do
      assert_difference 'SurveyRequest.count', -1 do
        SurveySender.send_surveys
      end
    end
  end
end
