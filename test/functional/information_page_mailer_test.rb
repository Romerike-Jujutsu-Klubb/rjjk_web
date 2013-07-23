# encoding: utf-8
require 'test_helper'

class InformationPageMailerTest < ActionMailer::TestCase
  test 'notify_outdated_pages' do
    mail = InformationPageMailer.notify_outdated_pages [], []
    assert_equal '[RJJK] Oppdatering av informasjonssider', mail.subject
    assert_equal %w(uwe@kubosch.no), mail.to
    assert_equal %w(test@jujutsu.no), mail.from
    assert_match 'Føgende sider trengs å sees over', mail.body.encoded
  end

  test 'send_weekly_page' do
    mail = InformationPageMailer.send_weekly_page
    assert_equal 'Send weekly page', mail.subject
    assert_equal %w(to@example.org), mail.to
    assert_equal %w(test@jujutsu.no), mail.from
    assert_match 'Hi', mail.body.encoded
  end

end
