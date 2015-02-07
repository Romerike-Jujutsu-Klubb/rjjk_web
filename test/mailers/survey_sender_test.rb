# encoding: utf-8
require 'test_helper'

class SurveySenderTest < ActionMailer::TestCase
  def test_send_surveys
    SurveySender.send_surveys
    assert_equal 1, ActionMailer::Base.deliveries.size

    mail = ActionMailer::Base.deliveries[0]
    assert_equal '[RJJK][test] First survey', mail.subject
    assert_equal 'Uwe Kubosch <uwe@kubosch.no>', mail.header['To'].to_s
    assert_equal %w(test@jujutsu.no), mail.from
    assert_match '<title>First survey</title>', mail.body.encoded
    assert_match "<a href=\"http://example.com/svar/397345097?email=&amp;key=0123456789abcdef0123456789abcdef01234567\" style=\"color: #454545\">Klikk her</a>\n                hvis du har problemer med å lese e-posten.",
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
  end
end
