require 'test_helper'

class SemesterMailerTest < ActionMailer::TestCase
  test 'missing_current_semester' do
    mail = SemesterMailer.missing_current_semester(members(:uwe))
    assert_equal 'Planlegge semesteret', mail.subject
    assert_equal %w(), mail.to
    assert_equal %w(noreply@test.jujutsu.no), mail.from
    assert_match 'Du trenger å starte å planlegge inneværende semester!', mail.body.encoded
  end

  test 'missing_next_semester' do
    mail = SemesterMailer.missing_next_semester(members(:uwe))
    assert_equal 'Planlegge neste semester', mail.subject
    assert_equal %w(), mail.to
    assert_equal %w(noreply@test.jujutsu.no), mail.from
    assert_match 'Du trenger å starte å planlegge neste semester!', mail.body.encoded
  end
end
