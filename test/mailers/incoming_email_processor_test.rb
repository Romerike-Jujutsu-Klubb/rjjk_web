# frozen_string_literal: true
require 'test_helper'

class IncomingEmailProcessorTest < ActionMailer::TestCase
  def test_forward_emails
    assert_mail_deliveries 6 do
      6.times { IncomingEmailProcessor.forward_emails }
    end

    mail = ActionMailer::Base.deliveries[0]
    assert_equal %w(test@jujutsu.no), mail.from
    assert_equal 'kasserer@jujutsu.no', mail.header['To'].to_s
    assert_equal ['kasiakrohn@gmail.com'], mail.smtp_envelope_to
    assert_equal '[TEST][RJJK] Melding til kasserer', mail.subject
    assert_match 'Meldingstekst kasserer', mail.body.encoded

    mail = ActionMailer::Base.deliveries[1]
    assert_equal %w(test@jujutsu.no), mail.from
    assert_equal 'materialforvalter@jujutsu.no', mail.header['To'].to_s
    assert_equal %w(tommy.musaus@hellvikhus.no), mail.smtp_envelope_to
    assert_equal '[TEST][RJJK] Melding til materialforvalter', mail.subject
    assert_match 'Meldingstekst materialforvalter', mail.body.encoded

    mail = ActionMailer::Base.deliveries[2]
    assert_equal %w(test@jujutsu.no), mail.from
    assert_equal 'medlem@jujutsu.no', mail.header['To'].to_s
    assert_equal ['srr@resvero.com'], mail.smtp_envelope_to
    assert_equal '[TEST][RJJK] Melding til medlem', mail.subject
    assert_match 'Meldingstekst medlem', mail.body.encoded

    mail = ActionMailer::Base.deliveries[3]
    assert_equal %w(test@jujutsu.no), mail.from
    assert_equal 'post@jujutsu.no', mail.header['To'].to_s
    assert_equal ['srr@resvero.com'], mail.smtp_envelope_to
    assert_equal '[TEST][RJJK] Melding til post', mail.subject
    assert_match 'Meldingstekst post', mail.body.encoded

    # Message to the board

    mail = ActionMailer::Base.deliveries[4]
    assert_equal %w(test@jujutsu.no), mail.from
    assert_equal 'styret@jujutsu.no', mail.header['To'].to_s
    assert_equal %w(lars@example.com sebastian@example.com admin@test.com), mail.smtp_envelope_to
    assert_equal %w(styret@jujutsu.no), mail.reply_to
    assert_equal '[TEST][RJJK][Styret] Melding til styret', mail.subject
    assert_match 'Meldingstekst styret', mail.body.encoded

    # Reply to the board

    mail = ActionMailer::Base.deliveries[5]
    assert_equal %w(test@jujutsu.no), mail.from
    assert_equal 'styret@jujutsu.no', mail.header['To'].to_s
    assert_equal %w(lars@example.com sebastian@example.com admin@test.com), mail.smtp_envelope_to
    assert_equal %w(styret@jujutsu.no), mail.reply_to
    assert_equal '[TEST][RJJK][Styret] Re: Melding til styret', mail.subject
    assert_match 'Meldingstekst svar til styret', mail.body.encoded
  end
end
