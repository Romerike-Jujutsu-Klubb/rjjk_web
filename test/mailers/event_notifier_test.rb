# frozen_string_literal: true

require 'test_helper'

class EventNotifierTest < ActionMailer::TestCase
  def test_send_attendance_plan
    assert_mail_deliveries(2) { EventNotifier.send_event_messages }

    mail = ActionMailer::Base.deliveries[0]
    assert_equal 'Event message one subject', mail.subject
    assert_equal %w[ei_one@example.com], mail.to
    assert_equal %w[test@jujutsu.no], mail.from
    assert_match %r{
          Har\ du\ problemer\ med\ å\ lese\ denne\ e-posten,\ klikk\ her:\s+
          https://example.com/events/980190962\s+Event\ message\ one\ subject\s+
          Event\ message\ one\ body
        }x,
        mail.parts[0].decoded
    assert_match 'Event message one subject', mail.body.encoded
    assert_match '<p>Event message one body</p>', mail.body.encoded

    mail = ActionMailer::Base.deliveries[1]
    assert_equal 'Event message two subject', mail.subject
    assert_equal %w[ei_one@example.com], mail.to
    assert_equal %w[test@jujutsu.no], mail.from
    assert_match %r{
          Har\ du\ problemer\ med\ å\ lese\ denne\ e-posten,\ klikk\ her:\s+
          https://example.com/events/980190962\s+Event\ message\ two\ subject\s+
          Event\ message\ two\ body}x,
        mail.parts[0].decoded
    assert_match '<p>Event message two body</p>', mail.body.encoded
  end
end
