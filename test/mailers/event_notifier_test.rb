# frozen_string_literal: true

require 'test_helper'

class EventNotifierTest < ActionMailer::TestCase
  def test_send_attendance_plan
    assert_mail_deliveries(0) do
      assert_mail_stored(4) do
        EventNotifier.send_event_messages
      end
    end

    mail = UserMessage.pending[0]
    assert_equal 'Event message one subject', mail.subject
    assert_equal ['newbie@example.com'], mail.to
    assert_equal %w[test@jujutsu.no], mail.from
    assert_match %r{
          Har\ du\ problemer\ med\ å\ lese\ denne\ e-posten,\ klikk\ her:\s+
          https://example.com/events/980190962\s+Event\ message\ one\ subject\s+
          Event\ message\ one\ body
        }x,
        mail.plain_body
    assert_match 'Event message one subject', mail.subject
    assert_match '<p>Event message one body</p>', mail.html_body

    mail = UserMessage.pending[1]
    assert_equal 'Event message one subject', mail.subject
    assert_equal ['leftie@example.com'], mail.to
    assert_equal %w[test@jujutsu.no], mail.from
    assert_match %r{
          Har\ du\ problemer\ med\ å\ lese\ denne\ e-posten,\ klikk\ her:\s+
          https://example.com/events/980190962\s+Event\ message\ one\ subject\s+
          Event\ message\ one\ body
        }x,
        mail.plain_body
    assert_match 'Event message one subject', mail.subject
    assert_match '<p>Event message one body</p>', mail.html_body

    mail = UserMessage.pending[2]
    assert_equal 'Event message two subject', mail.subject
    assert_equal ['newbie@example.com'], mail.to
    assert_equal %w[test@jujutsu.no], mail.from
    assert_match %r{
          Har\ du\ problemer\ med\ å\ lese\ denne\ e-posten,\ klikk\ her:\s+
          https://example.com/events/980190962\s+Event\ message\ two\ subject\s+
          Event\ message\ two\ body}x,
        mail.plain_body
    assert_match '<p>Event message two body</p>', mail.html_body

    mail = UserMessage.pending[3]
    assert_equal 'Event message two subject', mail.subject
    assert_equal ['leftie@example.com'], mail.to
    assert_equal %w[test@jujutsu.no], mail.from
    assert_match %r{
          Har\ du\ problemer\ med\ å\ lese\ denne\ e-posten,\ klikk\ her:\s+
          https://example.com/events/980190962\s+Event\ message\ two\ subject\s+
          Event\ message\ two\ body}x,
        mail.plain_body
    assert_match '<p>Event message two body</p>', mail.html_body
  end
end
