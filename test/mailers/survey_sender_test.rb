require 'test_helper'

class SurveySenderTest < ActionMailer::TestCase
  def test_send_surveys
    assert_mail_stored 1 do
      assert_no_difference 'SurveyRequest.count' do
        SurveySender.send_surveys
      end
    end

    mail = UserMessage.pending[0]
    assert_equal '[RJJK][TEST] First survey', mail.subject
    assert_equal ["\"Uwe Kubosch\" <admin@test.com>"], mail.to
    assert_equal %w(test@jujutsu.no), mail.from
    assert_match '<title>First survey</title>', mail.body
    assert_match %r{<a style="color: #454545" href="http://example.com/svar/397345097\?email=&amp;key=0123456789abcdef0123456789abcdef01234567">Klikk her</a>\s*hvis du har problemer med å lese e-posten.},
        mail.body
    assert_match "<p style=\"margin:0 0 10px 0; font-size:18px; color:#E20916;\">First survey</p>",
        mail.body
    assert_match '17. Oktober 2013', mail.body
    assert_match %r{<p[^>]*>First survey</p>}, mail.body
    assert_match 'First header text', mail.body
    assert_match 'First question', mail.body
    assert_match 'Second question', mail.body
    assert_match 'What do you think of this survey?', mail.body
    assert_match "For å svare på spørsmålene, kan du følge denne linken:\n  <a href=\"http://example.com/svar/397345097?key=0123456789abcdef0123456789abcdef01234567\">http://example.com/svar/397345097</a>",
        mail.body
    assert survey_requests(:unsent).sent_at

    assert_mail_stored 1, 1 do
      assert_difference 'SurveyRequest.count' do
        SurveySender.send_surveys
      end
    end

    mail = UserMessage.pending[1]
    assert_equal '[RJJK][TEST] First survey', mail.subject
    assert_equal ["\"Newbie Neuer\" <newbie@example.com>"], mail.to
    assert_equal %w(test@jujutsu.no), mail.from
    assert_match '<title>First survey</title>', mail.body
    assert_match %r{<a style="color: #454545" href="http://example.com/svar/98593450[89]\?email=&amp;key=[0-9a-f]{40}">Klikk her</a>\s*hvis du har problemer med å lese e-posten.},
        mail.body
    assert_match "<p style=\"margin:0 0 10px 0; font-size:18px; color:#E20916;\">First survey</p>",
        mail.body
    assert_match '17. Oktober 2013', mail.body
    assert_match %r{<p[^>]*>First survey</p>}, mail.body
    assert_match 'First header text', mail.body
    assert_match 'First question', mail.body
    assert_match 'Second question', mail.body
    assert_match 'What do you think of this survey?', mail.body
    assert_match %r{For å svare på spørsmålene, kan du følge denne linken:\s*<a href="http://example.com/svar/98593450[89]\?key=[0-9a-f]{40}">http://example.com/svar/98593450[89]</a>},
        mail.body

    assert_mail_stored 1, 2 do
      assert_no_difference 'SurveyRequest.count' do
        SurveySender.send_surveys
      end
    end

    mail = UserMessage.pending[2]
    assert_equal '[RJJK][TEST] First survey', mail.subject
    assert_equal ["\"Lars Bråten\" <lars@example.com>"], mail.to
    assert_equal %w(test@jujutsu.no), mail.from
    assert_match '<title>First survey</title>', mail.body
    assert_match %r{<a style="color: #454545" href="http://example.com/svar/985934507\?email=bGFyc0BleGFtcGxlLmNvbQ%3D%3D%0A&amp;key=random_token_string\+*">Klikk her</a>\s*hvis du har problemer med å lese e-posten.},
        mail.body
    assert_match "<p style=\"margin:0 0 10px 0; font-size:18px; color:#E20916;\">First survey</p>",
        mail.body
    assert_match '17. Oktober 2013', mail.body
    assert_match %r{<p[^>]*>First survey</p>}, mail.body
    assert_match 'First header text', mail.body
    assert_match 'First question', mail.body
    assert_match 'Second question', mail.body
    assert_match 'What do you think of this survey?', mail.body
    assert_match "For å svare på spørsmålene, kan du følge denne linken:\n  <a href=\"http://example.com/svar/985934507?key=random_token_string+++++++++++++++++++++\">http://example.com/svar/985934507</a>",
        mail.body
    assert survey_requests(:sent).reminded_at
  end
end
