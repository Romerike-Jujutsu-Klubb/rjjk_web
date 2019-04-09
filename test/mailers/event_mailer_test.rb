# frozen_string_literal: true

require 'test_helper'

class NewsletterMailerTest < ActionMailer::TestCase
  def test_event_invitee_message_with_multibyte_chars
    mail = EventMailer.event_invitee_message(event_invitee_messages(:one))
    assert_equal 'Så søte bær!', mail.subject
    assert_equal %w[newbie@example.com], mail.to
    assert_equal %w[test@jujutsu.no], mail.from
    assert_match(/S=C3=A5 s=C3=B8te b=C3=A6r!/, mail.body.encoded) # HTML version
    mail.deliver_now
  end
end
