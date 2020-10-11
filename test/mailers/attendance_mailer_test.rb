# frozen_string_literal: true

require 'test_helper'

class AttendanceMailerTest < ActionMailer::TestCase
  test 'plan' do
    mail = AttendanceMailer.plan(members(:lars))
    assert_equal 'Kommer du?', mail.subject
    assert_equal %w[lars@example.com], mail.to
    assert_equal %w[noreply@test.jujutsu.no], mail.from
    assert_match 'For å kunne ', mail.body.encoded
  end

  test 'message_reminder' do
    mail = AttendanceMailer.message_reminder(practices(:panda_2010_42), members(:lars))
    assert_equal 'Tema for morgendagens trening for Panda', mail.subject
    assert_equal ['lars@example.com'], mail.to
    assert_equal ['noreply@test.jujutsu.no'], mail.from
    assert_match 'Har du en melding til de som skal trene i morgen?', mail.body.encoded
  end

  test 'summary' do
    mail = AttendanceMailer.summary(practices(:panda_2010_42), group_schedules(:panda), users(:lars),
        [members(:lars)], [members(:uwe)])
    assert_equal 'Trening i kveld: 1 deltaker påmeldt', mail.subject
    assert_equal ['lars@example.com'], mail.to
    assert_equal ['noreply@test.jujutsu.no'], mail.from
    assert_match 'Følgende er påmeldt til trening i kveld', mail.body.encoded
  end

  test 'changes' do
    mail = AttendanceMailer.changes(practices(:panda_2010_42), group_schedules(:panda), users(:lars),
        [members(:uwe)], [members(:lars)], Member.all)
    assert_equal 'Trening i kveld: 1 ny deltaker påmeldt, 1 avmeldt', mail.subject
    assert_equal ['lars@example.com'], mail.to
    assert_equal ['noreply@test.jujutsu.no'], mail.from
    assert_match 'Nylig påmeldt', mail.body.encoded
  end

  test 'review' do
    mail = AttendanceMailer.review(users(:lars),
        [attendances(:lars_panda_2013_41)], [attendances(:lars_panda_2010_42)])
    assert_equal 'Hvordan var treningen?', mail.subject
    assert_equal %w[lars@example.com], mail.to
    assert_equal %w[noreply@test.jujutsu.no], mail.from
    assert_match 'https://example.com/attendances/review/2013/41/84385526/X?key=random_token_string',
        mail.body.encoded
  end
end
