# frozen_string_literal: true

require 'test_helper'

class InformationPageMailerTest < ActionMailer::TestCase
  test 'notify_outdated_pages' do
    mail = InformationPageMailer.notify_outdated_pages members(:lars), []
    assert_equal 'Oppdatering av informasjonssider', mail.subject
    assert_equal %w[lars@example.com], mail.to
    assert_equal %w[noreply@test.jujutsu.no], mail.from
    assert_match 'Føgende sider trengs å sees over', mail.body.encoded
  end

  test 'send_weekly_page' do
    mail = InformationPageMailer.send_weekly_page members(:lars), information_pages(:first)
    assert_equal 'Til info: My first article', mail.subject
    assert_equal %w[lars@example.com], mail.to
    assert_equal %w[test@jujutsu.no], mail.from
    assert_match 'A <strong>very</strong> interresting topic!', mail.body.encoded
  end
end
