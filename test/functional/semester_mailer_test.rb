# encoding: utf-8
require 'test_helper'

class SemesterMailerTest < ActionMailer::TestCase
  test 'missing_current_semester' do
    mail = SemesterMailer.missing_current_semester
    assert_equal '[RJJK] Planlegge semesteret', mail.subject
    assert_equal %w(uwe@kubosch.no), mail.to
    assert_equal %w(test@jujutsu.no), mail.from
    assert_match 'Du trenger å starte å planlegge inneværende semester!', mail.body.encoded
  end

  test 'missing_next_semester' do
    mail = SemesterMailer.missing_next_semester
    assert_equal '[RJJK] Planlegge neste semester', mail.subject
    assert_equal %w(uwe@kubosch.no), mail.to
    assert_equal %w(test@jujutsu.no), mail.from
    assert_match 'Du trenger å starte å planlegge neste semester!', mail.body.encoded
  end

end
