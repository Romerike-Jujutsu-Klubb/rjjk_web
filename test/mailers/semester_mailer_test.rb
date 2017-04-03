# frozen_string_literal: true

require 'test_helper'

class SemesterMailerTest < ActionMailer::TestCase
  test 'missing_session_dates' do
    mail = SemesterMailer.missing_session_dates(members(:uwe), groups(:voksne))
    assert_equal 'Planlegge neste semester', mail.subject
    assert_equal %w(), mail.to
    assert_equal %w(noreply@test.jujutsu.no), mail.from
    assert_match 'Du trenger å planlegge treningsstart og -stop for neste semester!',
        mail.body.encoded
  end
end
