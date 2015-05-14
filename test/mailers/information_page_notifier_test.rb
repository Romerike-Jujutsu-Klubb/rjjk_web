# encoding: utf-8
require 'test_helper'

class InformationPageNotifierTest < ActionMailer::TestCase
  def test_notify_outdated_pages
    InformationPageNotifier.notify_outdated_pages
    assert_equal 1, ActionMailer::Base.deliveries.size

    mail = ActionMailer::Base.deliveries[0]
    assert_equal '[RJJK][TEST] Oppdatering av informasjonssider', mail.subject
    assert_equal 'Uwe Kubosch <uwe@kubosch.no>', mail.header['To'].to_s
    assert_equal %w(test@jujutsu.no), mail.from
    assert_match 'Føgende sider trengs å sees over:', mail.body.encoded
    assert_match 'My second article', mail.body.encoded
    assert_match 'Se over at innholdet er OK, og huk av på "Revidert" før du lagrer.', mail.body.encoded
    assert_match 'Hvis siden ikke er relevant lenger, huk av på "Skjul".', mail.body.encoded
    assert_match 'Du vil få ny påmindelse om 6 måneder.', mail.body.encoded
  end

  def test_send_weekly_info_page
    assert InformationPageNotifier.send_weekly_info_page
    assert_equal 3, ActionMailer::Base.deliveries.size
    mail = ActionMailer::Base.deliveries[0]
    assert_equal '[RJJK][TEST] My first article', mail.subject
    assert_equal '"Lars Bråten" <uwe@kubosch.no>', mail.header['To'].to_s
    assert_equal %w(test@jujutsu.no), mail.from
    assert_match 'My first article', mail.body.encoded
    assert_match 'A very interresting topic!', mail.body.encoded

    email = ActionMailer::Base.deliveries[1]
    assert_equal '[RJJK][TEST] My first article', email.subject
    assert_equal 'Newbie Neuer <uwe@kubosch.no>', email.header['To'].to_s
    assert_equal %w(test@jujutsu.no), email.from
    assert_match 'My first article', email.body.encoded
    assert_match 'A very interresting topic!', email.body.encoded

    email = ActionMailer::Base.deliveries[2]
    assert_equal '[RJJK][TEST] My first article', email.subject
    assert_equal 'Uwe Kubosch <uwe@kubosch.no>', email.header['To'].to_s
    assert_equal %w(test@jujutsu.no), email.from
    assert_match 'My first article', email.body.encoded
    assert_match 'A very interresting topic!', email.body.encoded
  end

  def test_weekly_info_page_is_not_sent_to_leaving_members
    VCR.use_cassette 'GoogleMaps Uwe' do
      members(:uwe).update_attributes! left_on: 1.month.from_now
    end

    assert InformationPageNotifier.send_weekly_info_page
    assert_equal 2, ActionMailer::Base.deliveries.size

    email = ActionMailer::Base.deliveries[0]
    assert_equal '[RJJK][TEST] My first article', email.subject
    assert_equal '"Lars Bråten" <uwe@kubosch.no>', email.header['To'].to_s
    assert_equal %w(test@jujutsu.no), email.from
    assert_match 'My first article', email.body.encoded
    assert_match 'A very interresting topic!', email.body.encoded

    email = ActionMailer::Base.deliveries[1]
    assert_equal '[RJJK][TEST] My first article', email.subject
    assert_equal 'Newbie Neuer <uwe@kubosch.no>', email.header['To'].to_s
    assert_equal %w(test@jujutsu.no), email.from
    assert_match 'My first article', email.body.encoded
    assert_match 'A very interresting topic!', email.body.encoded

  end
end
