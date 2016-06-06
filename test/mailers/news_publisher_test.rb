# encoding: utf-8
require 'test_helper'

class NewsPublisherTest < ActionMailer::TestCase
  def test_send_news
    NewsPublisher.send_news
    assert_equal 4, ActionMailer::Base.deliveries.size

    mail = ActionMailer::Base.deliveries[0]
    assert_equal '[RJJK][TEST] My first news item', mail.subject
    assert_equal '"Lars Bråten" <uwe@kubosch.no>', mail.header['To'].to_s
    assert_equal %w(test@jujutsu.no), mail.from
    assert_match 'My first news item', mail.body.encoded
    assert_equal 2, mail.body.parts.size
    assert_match 'src="http://example.com/images/inline/980190962.jpg"', mail.body.parts[0].decoded
    assert_match 'src="http://example.com/images/inline/980190962.jpg"', mail.body.parts[1].decoded

    mail = ActionMailer::Base.deliveries[1]
    assert_equal '[RJJK][TEST] My first news item', mail.subject
    assert_equal 'Uwe Kubosch <uwe@kubosch.no>', mail.header['To'].to_s
    assert_equal %w(test@jujutsu.no), mail.from
    assert_match 'My first news item', mail.body.encoded

    mail = ActionMailer::Base.deliveries[2]
    assert_equal '[RJJK][TEST] My first news item', mail.subject
    assert_equal 'Sebastian Kubosch <uwe@kubosch.no>', mail.header['To'].to_s
    assert_equal %w(test@jujutsu.no), mail.from
    assert_match 'My first news item', mail.body.encoded

    mail = ActionMailer::Base.deliveries[3]
    assert_equal '[RJJK][TEST] My first news item', mail.subject
    assert_equal 'Newbie Neuer <uwe@kubosch.no>', mail.header['To'].to_s
    assert_equal %w(test@jujutsu.no), mail.from
    assert_match 'My first news item', mail.body.encoded
  end

  def test_news_is_not_sent_to_leaving_members
    VCR.use_cassette 'GoogleMaps Uwe' do
      members(:uwe).update_attributes! left_on: 1.month.from_now
    end
    assert NewsPublisher.send_news
    assert_equal 3, ActionMailer::Base.deliveries.size
  end
end
