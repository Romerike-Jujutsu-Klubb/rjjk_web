require 'test_helper'

class AttendanceMailerTest < ActionMailer::TestCase
  test 'plan' do
    mail = AttendanceMailer.plan(members(:lars))
    assert_equal '[RJJK] Kommer du?', mail.subject
    assert_equal %w(uwe@kubosch.no), mail.to
    assert_equal %w(test@jujutsu.no), mail.from
    assert_match 'For å kunne ', mail.body.encoded
  end

  test 'review' do
    mail = AttendanceMailer.review(members(:lars), [attendances(:lars_panda_2013_41)], [attendances(:lars_panda_2010_42)])
    assert_equal '[RJJK] Hvordan var treningen?', mail.subject
    assert_equal %w(uwe@kubosch.no), mail.to
    assert_equal %w(test@jujutsu.no), mail.from
    assert_match 'http://example.com/attendances/review/2013/41/84385526/X?key=random_token_string+++++++++++++++++++++',
        mail.body.encoded
  end
end
