# encoding: utf-8
require 'test_helper'

class AttendanceMailerTest < ActionMailer::TestCase
  test 'plan' do
    mail = AttendanceMailer.plan(members(:lars))
    assert_equal '[RJJK] Kommer du?', mail.subject
    assert_equal %w(uwe@kubosch.no), mail.to
    assert_equal %w(test@jujutsu.no), mail.from
    assert_match 'For å kunne ', mail.body.encoded
  end
end
