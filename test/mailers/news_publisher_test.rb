# frozen_string_literal: true

require 'test_helper'

class NewsPublisherTest < ActionMailer::TestCase
  def test_send_news
    VCR.use_cassette 'GoogleMaps Uwe' do
      NewsPublisher.send_news
    end
    assert_equal 5, UserMessage.pending.size

    mail = UserMessage.pending[0]
    assert_equal 'My first news item', mail.subject
    assert_equal ['uwe@example.com'], mail.to
    assert_equal %w[test@jujutsu.no], mail.from
    assert_match 'My first news item', mail.html_body
    assert_match 'src="https://example.com/images/inline/980190962.jpg"', mail.html_body
    assert_match 'src="https://example.com/images/inline/980190962.jpg"', mail.plain_body

    mail = UserMessage.pending[1]
    assert_equal 'My first news item', mail.subject
    assert_equal ['lars@example.com'], mail.to
    assert_equal %w[test@jujutsu.no], mail.from

    mail = UserMessage.pending[2]
    assert_equal 'My first news item', mail.subject
    assert_equal ['sebastian@example.com', 'uwe@example.com'], mail.to
    assert_equal %w[test@jujutsu.no], mail.from
    assert_match 'My first news item', mail.html_body

    mail = UserMessage.pending[3]
    assert_equal 'My first news item', mail.subject
    assert_equal ['neuer@example.com', 'newbie@example.com'], mail.to
    assert_equal %w[test@jujutsu.no], mail.from
    assert_match 'My first news item', mail.html_body
  end

  def test_news_is_not_sent_to_leaving_members
    VCR.use_cassette('GoogleMaps Uwe') { members(:uwe).update! left_on: 1.month.from_now }
    VCR.use_cassette('GoogleMaps Uwe') { assert NewsPublisher.send_news }
    assert_equal 4, UserMessage.pending.size
  end
end
