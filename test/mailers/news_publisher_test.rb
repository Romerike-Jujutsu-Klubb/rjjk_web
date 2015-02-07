# encoding: utf-8
require 'test_helper'

class NewsPublisherTest < ActionMailer::TestCase
  def test_send_news
    NewsPublisher.send_news
    assert_equal 4, ActionMailer::Base.deliveries.size

    mail = ActionMailer::Base.deliveries[0]
    assert_equal '[RJJK][test] My first news item', mail.subject
    assert_equal '"Lars Bråten" <uwe@kubosch.no>', mail.header['To'].to_s
    assert_equal %w(test@jujutsu.no), mail.from
    assert_match 'My first news item', mail.body.encoded

    mail = ActionMailer::Base.deliveries[1]
    assert_equal '[RJJK][test] My first news item', mail.subject
    assert_equal 'Uwe Kubosch <uwe@kubosch.no>', mail.header['To'].to_s
    assert_equal %w(test@jujutsu.no), mail.from
    assert_match 'My first news item', mail.body.encoded

    mail = ActionMailer::Base.deliveries[2]
    assert_equal '[RJJK][test] My first news item', mail.subject
    assert_equal 'Sebastian Kubosch <uwe@kubosch.no>', mail.header['To'].to_s
    assert_equal %w(test@jujutsu.no), mail.from
    assert_match 'My first news item', mail.body.encoded
  end

  def test_weekly_info_page_is_not_sent_to_leaving_members
    members(:uwe).update_attributes! left_on: 1.month.from_now
    assert NewsPublisher.send_news
    assert_equal 3, ActionMailer::Base.deliveries.size
  end
end
