# encoding: utf-8
require 'test_helper'

class IncomingEmailProcessorTest < ActionMailer::TestCase
  def test_forward_emails
    IncomingEmailProcessor.forward_emails
    assert_equal 1, ActionMailer::Base.deliveries.size

    mail = ActionMailer::Base.deliveries[0]
    assert_equal %w(test@jujutsu.no), mail.from
    assert_equal '"[RJJK][TEST][Kasserer] Kasia Krohn <kasiakrohn@gmail.com>" <uwe@kubosch.no>', mail.header['To'].to_s
    assert_equal 'Melding til kasserer', mail.subject
    assert_match 'Meldingstekst kasserer', mail.body.encoded

    # mail = ActionMailer::Base.deliveries[1]
    # assert_equal '[RJJK][test] My first news item', mail.subject
    # assert_equal 'Uwe Kubosch <uwe@kubosch.no>', mail.header['To'].to_s
    # assert_equal %w(test@jujutsu.no), mail.from
    # assert_match 'My first news item', mail.body.encoded
    #
    # mail = ActionMailer::Base.deliveries[2]
    # assert_equal '[RJJK][test] My first news item', mail.subject
    # assert_equal 'Sebastian Kubosch <uwe@kubosch.no>', mail.header['To'].to_s
    # assert_equal %w(test@jujutsu.no), mail.from
    # assert_match 'My first news item', mail.body.encoded
    #
    # mail = ActionMailer::Base.deliveries[3]
    # assert_equal '[RJJK][test] My first news item', mail.subject
    # assert_equal 'Sebastian Kubosch <uwe@kubosch.no>', mail.header['To'].to_s
    # assert_equal %w(test@jujutsu.no), mail.from
    # assert_match 'My first news item', mail.body.encoded
    #
    # mail = ActionMailer::Base.deliveries[4]
    # assert_equal '[RJJK][test] My first news item', mail.subject
    # assert_equal 'Sebastian Kubosch <uwe@kubosch.no>', mail.header['To'].to_s
    # assert_equal %w(test@jujutsu.no), mail.from
    # assert_match 'My first news item', mail.body.encoded
    #
    # mail = ActionMailer::Base.deliveries[5]
    # assert_equal '[RJJK][test] My first news item', mail.subject
    # assert_equal 'Sebastian Kubosch <uwe@kubosch.no>', mail.header['To'].to_s
    # assert_equal %w(test@jujutsu.no), mail.from
    # assert_match 'My first news item', mail.body.encoded
  end

  def test_weekly_info_page_is_not_sent_to_leaving_members
    VCR.use_cassette 'GoogleMaps Uwe' do
      members(:uwe).update_attributes! left_on: 1.month.from_now
    end
    assert NewsPublisher.send_news
    assert_equal 3, ActionMailer::Base.deliveries.size
  end
end
