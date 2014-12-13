# encoding: utf-8

require 'test_helper'

class NewsletterMailerTest < ActionMailer::TestCase
  def test_newsletter
    mail = NewsletterMailer.newsletter(news_items(:first), members(:lars))
    assert_equal '[RJJK][test] My first news item', mail.subject
    assert_equal %w(uwe@kubosch.no), mail.to
    assert_equal %w(test@jujutsu.no), mail.from
    assert_match 'Har du problemer', mail.body.encoded
  end

  def test_event_invitee_message_with_multibyte_chars
    mail = NewsletterMailer.event_invitee_message(event_invitee_messages(:one))
    assert_equal '[RJJK][test] Så søte bær!', mail.subject
    assert_equal %w(uwe@kubosch.no), mail.to
    assert_equal %w(test@jujutsu.no), mail.from
    assert_match /S=C3=A5 s=C3=B8te b=C3=A6r!/, mail.body.encoded # HTML version
    #assert_match /SÅ SØTE BÆR!/, mail.body.encoded # text version
    mail.deliver
  end

end
