# encoding: utf-8
require 'test_helper'

class InformationPageMailerTest < ActionMailer::TestCase
  test 'notify_outdated_pages' do
    mail = InformationPageMailer.notify_outdated_pages members(:lars), []
    assert_equal '[RJJK][TEST] Oppdatering av informasjonssider', mail.subject
    assert_equal %w(uwe@kubosch.no), mail.to
    assert_equal %w(test@jujutsu.no), mail.from
    assert_match 'Føgende sider trengs å sees over', mail.body.encoded
  end

  test 'send_weekly_page' do
    mail = InformationPageMailer.send_weekly_page members(:lars), information_pages(:first)
    assert_equal '[RJJK][TEST] Til info: My first article', mail.subject
    assert_equal %w(uwe@kubosch.no), mail.to
    assert_equal %w(test@jujutsu.no), mail.from
    assert_match 'My first article', mail.body.encoded
    assert_match 'A very interresting topic!', mail.body.encoded
  end

end
