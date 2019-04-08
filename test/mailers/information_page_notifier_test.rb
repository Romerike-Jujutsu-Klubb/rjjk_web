# frozen_string_literal: true

require 'test_helper'

class InformationPageNotifierTest < ActionMailer::TestCase
  def test_notify_outdated_pages
    InformationPageNotifier.notify_outdated_pages
    assert_equal 1, UserMessage.pending.size

    mail = UserMessage.pending[0]
    assert_equal 'Oppdatering av informasjonssider', mail.subject
    assert_equal ['uwe@example.com'], mail.to
    assert_equal %w[noreply@test.jujutsu.no], mail.from
    assert_match 'Føgende sider trengs å sees over:', mail.body
    assert_match 'My second article', mail.body
    assert_match 'Se over at innholdet er OK, og huk av på "Revidert" før du lagrer.', mail.body
    assert_match 'Hvis siden ikke er relevant lenger, huk av på "Skjul".', mail.body
    assert_match 'Du vil få ny påmindelse om 6 måneder.', mail.body
  end

  def test_send_weekly_info_page
    assert InformationPageNotifier.send_weekly_info_page
    assert_equal 5, UserMessage.pending.size

    mail = UserMessage.pending[0]
    assert_equal 'Til info: My first article', mail.subject
    assert_equal ['lars@example.com'], mail.to
    assert_equal %w[test@jujutsu.no], mail.from
    assert_match 'A <strong>very</strong> interresting topic!', mail.body

    email = UserMessage.pending[1]
    assert_equal 'Til info: My first article', email.subject
    assert_equal ['neuer@example.com', 'newbie@example.com'], email.to
    assert_equal %w[test@jujutsu.no], email.from
    assert_match 'A <strong>very</strong> interresting topic!', email.body

    email = UserMessage.pending[2]
    assert_equal 'Til info: My first article', email.subject
    assert_equal ['oldie@example.com'], email.to
    assert_equal %w[test@jujutsu.no], email.from
    assert_match 'A <strong>very</strong> interresting topic!', email.body

    email = UserMessage.pending[3]
    assert_equal 'Til info: My first article', email.subject
    assert_equal ['sebastian@example.com', 'uwe@example.com'], email.to
    assert_equal %w[test@jujutsu.no], email.from
    assert_match 'A <strong>very</strong> interresting topic!', email.body

    email = UserMessage.pending[4]
    assert_equal 'Til info: My first article', email.subject
    assert_equal ['uwe@example.com'], email.to
    assert_equal %w[test@jujutsu.no], email.from
    assert_match 'A <strong>very</strong> interresting topic!', email.body
  end

  def test_weekly_info_page_is_not_sent_to_leaving_members
    VCR.use_cassette 'GoogleMaps Uwe' do
      members(:uwe).update! left_on: 1.month.from_now
    end

    assert InformationPageNotifier.send_weekly_info_page
    assert_equal 4, UserMessage.pending.size

    email = UserMessage.pending[0]
    assert_equal 'Til info: My first article', email.subject
    assert_equal ['lars@example.com'], email.to
    assert_equal %w[test@jujutsu.no], email.from
    assert_match 'A <strong>very</strong> interresting topic!', email.body

    email = UserMessage.pending[1]
    assert_equal 'Til info: My first article', email.subject
    assert_equal ['neuer@example.com', 'newbie@example.com'], email.to
    assert_equal %w[test@jujutsu.no], email.from
    assert_match 'A <strong>very</strong> interresting topic!', email.body

    email = UserMessage.pending[2]
    assert_equal 'Til info: My first article', email.subject
    assert_equal ['oldie@example.com'], email.to
    assert_equal %w[test@jujutsu.no], email.from
    assert_match 'A <strong>very</strong> interresting topic!', email.body

    email = UserMessage.pending[3]
    assert_equal 'Til info: My first article', email.subject
    assert_equal ['sebastian@example.com', 'uwe@example.com'], email.to
    assert_equal %w[test@jujutsu.no], email.from
    assert_match 'A <strong>very</strong> interresting topic!', email.body
  end
end
