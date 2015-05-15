# encoding: utf-8
require 'test_helper'

class IncomingEmailProcessorTest < ActionMailer::TestCase
  def test_forward_emails
    5.times { IncomingEmailProcessor.forward_emails }
    assert_equal 9, ActionMailer::Base.deliveries.size

    mail = ActionMailer::Base.deliveries[0]
    assert_equal %w(test@jujutsu.no), mail.from
    assert_equal '"[RJJK][TEST][Kasserer] Kasia Krohn <kasiakrohn@gmail.com>" <uwe@kubosch.no>', mail.header['To'].to_s
    assert_equal 'Melding til kasserer', mail.subject
    assert_match 'Meldingstekst kasserer', mail.body.encoded

    mail = ActionMailer::Base.deliveries[1]
    assert_equal %w(test@jujutsu.no), mail.from
    assert_equal '"[RJJK][TEST][Materialforvalter] Tommy Musaus <tommy.musaus@hellvikhus.no>" <uwe@kubosch.no>', mail.header['To'].to_s
    assert_equal 'Melding til materialforvalter', mail.subject
    assert_match 'Meldingstekst materialforvalter', mail.body.encoded

    mail = ActionMailer::Base.deliveries[2]
    assert_equal %w(test@jujutsu.no), mail.from
    assert_equal '"[RJJK][TEST][Medlem] Svein Robert Rolijordet <srr@resvero.com>" <uwe@kubosch.no>', mail.header['To'].to_s
    assert_equal 'Melding til medlem', mail.subject
    assert_match 'Meldingstekst medlem', mail.body.encoded

    mail = ActionMailer::Base.deliveries[3]
    assert_equal %w(test@jujutsu.no), mail.from
    assert_equal '"[RJJK][TEST][Post] Svein Robert Rolijordet <srr@resvero.com>" <uwe@kubosch.no>', mail.header['To'].to_s
    assert_equal 'Melding til post', mail.subject
    assert_match 'Meldingstekst post', mail.body.encoded

    assert_styret_email(4, 'Svein Robert Rolijordet', 'srr@resvero.com')
    assert_styret_email(5, 'Trond Evensen', 'trondevensen@icloud.com')
    assert_styret_email(6, 'Kasia Krohn', 'kasiakrohn@gmail.com')
    assert_styret_email(7, 'Torstein Resløkken', 'reslokken@gmail.com')
    assert_styret_email(8, 'Uwe Kubosch', 'uwe@kubosch.no')
  end

  test 'weekly_info_page_is_not_sent_to_leaving_members' do
    VCR.use_cassette 'GoogleMaps Uwe' do
      members(:uwe).update_attributes! left_on: 1.month.from_now
    end
    assert NewsPublisher.send_news
    assert_equal 3, ActionMailer::Base.deliveries.size
  end

  private

  def assert_styret_email(mail_index, name, email)
    mail = ActionMailer::Base.deliveries[mail_index]
    assert_equal %w(test@jujutsu.no), mail.from
    assert_equal %Q{"RJJK Styret <#{email}>" <uwe@kubosch.no>},
        mail.header['To'].to_s
    assert_equal %w{uwe@kubosch.no}, mail.smtp_envelope_to
    assert_equal %w(styret@jujutsu.no), mail.reply_to
    assert_equal '[RJJK][TEST][Styret] Melding til styret', mail.subject
    assert_match 'Meldingstekst styret', mail.body.encoded
  end

end
