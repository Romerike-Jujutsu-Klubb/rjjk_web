# encoding: utf-8
require 'test_helper'

class IncomingEmailProcessorTest < ActionMailer::TestCase
  def test_forward_emails
    assert_mail_deliveries 5 do
      5.times { IncomingEmailProcessor.forward_emails }
    end

    mail = ActionMailer::Base.deliveries[0]
    assert_equal %w(test@jujutsu.no), mail.from
    assert_equal 'kasserer@test.jujutsu.no', mail.header['To'].to_s
    assert_equal ['kasiakrohn@gmail.com'], mail.smtp_envelope_to
    assert_equal '[TEST][RJJK] Melding til kasserer', mail.subject
    assert_match 'Meldingstekst kasserer', mail.body.encoded

    mail = ActionMailer::Base.deliveries[1]
    assert_equal %w(test@jujutsu.no), mail.from
    assert_equal 'materialforvalter@test.jujutsu.no', mail.header['To'].to_s
    assert_equal %w(tommy.musaus@hellvikhus.no), mail.smtp_envelope_to
    assert_equal '[TEST][RJJK] Melding til materialforvalter', mail.subject
    assert_match 'Meldingstekst materialforvalter', mail.body.encoded

    mail = ActionMailer::Base.deliveries[2]
    assert_equal %w(test@jujutsu.no), mail.from
    assert_equal 'medlem@test.jujutsu.no', mail.header['To'].to_s
    assert_equal ['srr@resvero.com'], mail.smtp_envelope_to
    assert_equal '[TEST][RJJK] Melding til medlem', mail.subject
    assert_match 'Meldingstekst medlem', mail.body.encoded

    mail = ActionMailer::Base.deliveries[3]
    assert_equal %w(test@jujutsu.no), mail.from
    assert_equal 'post@test.jujutsu.no', mail.header['To'].to_s
    assert_equal ['srr@resvero.com'], mail.smtp_envelope_to
    assert_equal '[TEST][RJJK] Melding til post', mail.subject
    assert_match 'Meldingstekst post', mail.body.encoded

    mail = ActionMailer::Base.deliveries[4]
    assert_equal %w(test@jujutsu.no), mail.from
    assert_equal 'styret@test.jujutsu.no',
        mail.header['To'].to_s
    assert_equal %w(srr@resvero.com trondevensen@icloud.com kasiakrohn@gmail.com reslokken@gmail.com uwe@kubosch.no),
        mail.smtp_envelope_to
    assert_equal %w(styret@jujutsu.no), mail.reply_to
    assert_equal '[TEST][RJJK][Styret] Melding til styret', mail.subject
    assert_match 'Meldingstekst styret', mail.body.encoded
  end

end
