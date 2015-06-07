# encoding: utf-8
require 'test_helper'

class SurveySenderTest < ActionMailer::TestCase
  def test_send_surveys
    assert_mail_deliveries 1 do
      assert_no_difference 'SurveyRequest.count' do
        SurveySender.send_surveys
      end
    end

    mail = ActionMailer::Base.deliveries[0]
    assert_equal '[RJJK][TEST] First survey', mail.subject
    assert_equal 'Uwe Kubosch <uwe@kubosch.no>', mail.header['To'].to_s
    assert_equal %w(test@jujutsu.no), mail.from
    assert_match '<title>First survey</title>', mail.body.encoded
    assert_match %r{<a style="color: #454545" href="http://example.com/svar/397345097\?email=&amp;key=0123456789abcdef0123456789abcdef01234567">Klikk her</a>\s*hvis du har problemer med å lese e-posten.},
        mail.body.decoded
    assert_match "<p style=\"margin:0 0 10px 0; font-size:18px; color:#E20916;\">First survey</p>",
        mail.body.decoded
    assert_match '17. Oktober 2013', mail.body.encoded
    assert_match %r{<p[^>]*>First survey</p>}, mail.body.decoded
    assert_match 'First header text', mail.body.encoded
    assert_match 'First question', mail.body.encoded
    assert_match 'Second question', mail.body.encoded
    assert_match 'What do you think of this survey?', mail.body.encoded
    assert_match "For å svare på spørsmålene, kan du følge denne linken:\n  <a href=\"http://example.com/svar/397345097?key=0123456789abcdef0123456789abcdef01234567\">http://example.com/svar/397345097</a>",
        mail.body.decoded
    assert survey_requests(:unsent).sent_at

    assert_difference 'SurveyRequest.count' do
      SurveySender.send_surveys
    end
    assert_equal 2, ActionMailer::Base.deliveries.size

    mail = ActionMailer::Base.deliveries[1]
    assert_equal '[RJJK][TEST] First survey', mail.subject
    assert_equal 'Newbie Neuer <uwe@kubosch.no>', mail.header['To'].to_s
    assert_equal %w(test@jujutsu.no), mail.from
    assert_match '<title>First survey</title>', mail.body.encoded
    assert_match %r{<a style="color: #454545" href="http://example.com/svar/98593450[89]\?email=&amp;key=[0-9a-f]{40}">Klikk her</a>\s*hvis du har problemer med å lese e-posten.},
        mail.body.decoded
    assert_match "<p style=\"margin:0 0 10px 0; font-size:18px; color:#E20916;\">First survey</p>",
        mail.body.decoded
    assert_match '17. Oktober 2013', mail.body.encoded
    assert_match %r{<p[^>]*>First survey</p>}, mail.body.decoded
    assert_match 'First header text', mail.body.encoded
    assert_match 'First question', mail.body.encoded
    assert_match 'Second question', mail.body.encoded
    assert_match 'What do you think of this survey?', mail.body.encoded
    assert_match %r{For å svare på spørsmålene, kan du følge denne linken:\s*<a href="http://example.com/svar/98593450[89]\?key=[0-9a-f]{40}">http://example.com/svar/98593450[89]</a>},
        mail.body.decoded

    assert_mail_deliveries 3 do
      assert_no_difference 'SurveyRequest.count' do
        SurveySender.send_surveys
      end
    end

    mail = ActionMailer::Base.deliveries[2]
    assert_equal '[RJJK][TEST] First survey', mail.subject
    assert_equal '"Lars Bråten" <uwe@kubosch.no>', mail.header['To'].to_s
    assert_equal %w(test@jujutsu.no), mail.from
    assert_match '<title>First survey</title>', mail.body.encoded
    assert_match %r{<a style="color: #454545" href="http://example.com/svar/985934507\?email=bGFyc0BleGFtcGxlLmNvbQ%3D%3D%0A&amp;key=random_token_string\+{21}">Klikk her</a>\s*hvis du har problemer med å lese e-posten.},
        mail.body.decoded
    assert_match "<p style=\"margin:0 0 10px 0; font-size:18px; color:#E20916;\">First survey</p>",
        mail.body.decoded
    assert_match '17. Oktober 2013', mail.body.encoded
    assert_match %r{<p[^>]*>First survey</p>}, mail.body.decoded
    assert_match 'First header text', mail.body.encoded
    assert_match 'First question', mail.body.encoded
    assert_match 'Second question', mail.body.encoded
    assert_match 'What do you think of this survey?', mail.body.encoded
    assert_match "For å svare på spørsmålene, kan du følge denne linken:\n  <a href=\"http://example.com/svar/985934507?key=random_token_string+++++++++++++++++++++\">http://example.com/svar/985934507</a>",
        mail.body.decoded
    assert survey_requests(:sent).reminded_at
  end
end
