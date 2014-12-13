# encoding: utf-8
require 'test_helper'

class SurveySenderTest < ActionMailer::TestCase
  def test_send_surveys
    SurveySender.send_surveys
    assert_equal 1, ActionMailer::Base.deliveries.size

    mail = ActionMailer::Base.deliveries[0]
    assert_equal '[RJJK][test] First survey', mail.subject
    assert_equal '"Lars Bråten" <uwe@kubosch.no>', mail.header['To'].to_s
    assert_equal %w(test@jujutsu.no), mail.from
    assert_match '<title>First survey</title>', mail.body.encoded
    assert_match "<a href=3D\"http://example.com/svar/985934507?email=3DbGFy=\r\nc0BleGFtcGxlLmNvbQ%3D%3D%0A&amp;key=3Drandom_token_string\" style=3D\"color=\r\n: #454545\">Klikk her</a>\r\n                hvis du har problemer med =C3=A5 lese e-posten.", mail.body.encoded
    assert_match "<p style=3D\"margin:0 0 10px 0; font-size:18px; =\r\ncolor:#E20916;\">First survey</p>", mail.body.encoded
    assert_match '17. Oktober 2013', mail.body.encoded
    assert_match '<h2>First survey</h2>', mail.body.encoded
    assert_match 'First header text', mail.body.encoded
    assert_match 'First question', mail.body.encoded
    assert_match 'Second question', mail.body.encoded
    assert_match 'What do you think of this survey?', mail.body.encoded
    assert_match "For =C3=A5 svare p=C3=A5 sp=C3=B8rsm=C3=A5lene, kan du f=C3=B8lge denne=\r\n linken:\r\n  <a href=3D\"http://example.com/svar/985934507?key=3Drandom_token_string\"=\r\n>http://example.com/svar/985934507</a>", mail.body.encoded
  end
end
