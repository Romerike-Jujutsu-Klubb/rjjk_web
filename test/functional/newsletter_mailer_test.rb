require 'test_helper'

class NewsletterMailerTest < ActionMailer::TestCase
  test "newsletter" do
    mail = NewsletterMailer.newsletter(news_items(:first), users(:tesla))
    assert_equal "Newsletter", mail.subject
    assert_equal ["uwe@kubosch.no"], mail.to
    assert_equal ["post@jujutsu.no"], mail.from
    assert_match "Har du problemer", mail.body.encoded
  end

end
