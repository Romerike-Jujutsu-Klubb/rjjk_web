# frozen_string_literal: true
require 'test_helper'

class EventNotifierTest < ActionMailer::TestCase
  def test_send_attendance_plan
    assert_mail_deliveries(2) { EventNotifier.send_event_messages }

    mail = ActionMailer::Base.deliveries[0]
    assert_equal 'Event message one subject', mail.subject
    assert_equal %w(ei_one@example.com), mail.to
    assert_equal %w(test@jujutsu.no), mail.from
    assert_match %r{
          Har\ du\ problemer\ med\ å\ lese\ denne\ e-posten,\ klikk\ her:\s+
          http://example.com/events/980190962\s+Event\ message\ one\ subject\s+
          Event\ message\ one\ body
        }x,
        mail.parts[0].decoded
    assert_match '<title>Event message one subject</title>', mail.body.encoded
    assert_match %r{
          <a(\ href="http://example.com/event_invitee_messages/98019096(3|4)"
          |\ style="color:\ \#454545"){2}>Klikk\ her</a>\s*
          hvis\ du\ har\ problemer\ med\ å\ lese\ meldingen.
        }x,
        mail.body.parts[1].decoded
    assert_match "<p style=3D\"margin:0 0 10px 0; font-size:18px; =\r\ncolor:#E20916;\">" \
        'Event message one subject</p>',
        mail.body.encoded
    assert_match(/L=C3=B8rdag 19\. August kl\. 13:37\s+2017/, mail.body.encoded.gsub(/=\r\n/, ''))
    assert_match '<p>Event message one body</p>', mail.body.encoded

    mail = ActionMailer::Base.deliveries[1]
    assert_equal 'Event message two subject', mail.subject
    assert_equal %w(ei_one@example.com), mail.to
    assert_equal %w(test@jujutsu.no), mail.from
    assert_match %r{
          Har\ du\ problemer\ med\ å\ lese\ denne\ e-posten,\ klikk\ her:\s+
          http://example.com/events/980190962\s+Event\ message\ two\ subject\s+
          Event\ message\ two\ body}x,
        mail.parts[0].decoded
    assert_match '<title>Event message two subject</title>', mail.body.encoded
    assert_match %r{<a\ style="color:\ \#454545"
          \ href="http://example.com/event_invitee_messages/98019096[45]">
          Klikk\ her</a>\s*hvis\ du\ har\ problemer\ med\ å\ lese\ meldingen.}x,
        mail.body.parts[1].decoded
    assert_match '<p style="margin:0 0 10px 0; font-size:18px; color:#E20916;">' \
        'Event message two subject</p>',
        mail.parts[1].decoded
    assert_match(/L=C3=B8rdag 19\. August kl\. 13:37\s+2017/, mail.body.encoded)
    assert_match '<p>Event message two body</p>', mail.body.encoded
  end
end
