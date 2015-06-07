# encoding: utf-8
require 'test_helper'

class EventNotifierTest < ActionMailer::TestCase
  def test_send_attendance_plan
    assert_mail_deliveries(2) { EventNotifier.send_event_messages }

    mail = ActionMailer::Base.deliveries[0]
    assert_equal '[RJJK][TEST] Event message one subject', mail.subject
    assert_equal %w(uwe@kubosch.no), mail.to
    assert_equal %w(test@jujutsu.no), mail.from
    assert_match "Har du problemer med =C3=A5 lese denne e-posten, klikk her:\r\nhttp://example.com/events/980190962\r\n\r\nEvent message one subject\r\n\r\n\r\nEvent message one body\r\n\r\n\r\n", mail.body.encoded
    assert_match '<title>Event message one subject</title>', mail.body.encoded
    assert_match %r{<a( href="http://example.com/event_invitee_messages/98019096(3|4)"| style="color: #454545"){2}>Klikk her</a>\s*hvis du har problemer med å lese meldingen.},
        mail.body.parts[1].decoded
    assert_match "<p style=3D\"margin:0 0 10px 0; font-size:18px; =\r\ncolor:#E20916;\">Event message one subject</p>", mail.body.encoded
    assert_match "L=C3=B8rdag 18. Februar 18. kl. 13:37=\r\n\r\n                          2012", mail.body.encoded
    assert_match '<p>Event message one body</p>', mail.body.encoded

    mail = ActionMailer::Base.deliveries[1]
    assert_equal '[RJJK][TEST] Event message two subject', mail.subject
    assert_equal %w(uwe@kubosch.no), mail.to
    assert_equal %w(test@jujutsu.no), mail.from
    assert_match "Har du problemer med =C3=A5 lese denne e-posten, klikk her:\r\nhttp://example.com/events/980190962\r\n\r\nEvent message two subject\r\n\r\n\r\nEvent message two body\r\n\r\n\r\n", mail.body.encoded
    assert_match '<title>Event message two subject</title>', mail.body.encoded
    assert_match %r{<a style="color: #454545" href="http://example.com/event_invitee_messages/98019096[45]">Klikk her</a>\s*hvis du har problemer med å lese meldingen.},
        mail.body.parts[1].decoded
    assert_match "<p style=3D\"margin:0 0 10px 0; font-size:18px; =\r\ncolor:#E20916;\">Event message two subject</p>", mail.body.encoded
    assert_match "L=C3=B8rdag 18. Februar 18. kl. 13:37=\r\n\r\n                          2012", mail.body.encoded
    assert_match '<p>Event message two body</p>', mail.body.encoded
  end
end
