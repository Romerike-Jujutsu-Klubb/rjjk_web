# frozen_string_literal: true

require 'test_helper'

class NewsletterMailerTest < ActionMailer::TestCase
  def test_newsletter
    mail = NewsletterMailer.newsletter(news_items(:first), members(:lars))
    assert_equal 'My first news item', mail.subject
    assert_equal %w[lars@example.com], mail.to
    assert_equal %w[noreply@test.jujutsu.no], mail.from
    assert_match 'Har du problemer', mail.body.encoded
  end
end
