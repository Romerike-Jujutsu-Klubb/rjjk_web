# frozen_string_literal: true

require 'test_helper'

class RoleTest < ActiveSupport::TestCase
  test 'current appointments and elections change when role changed' do
    r = roles(:chairman)
    assert_equal 0, r.appointments.size
    assert_equal 2, r.elections.size

    r.update! years_on_the_board: nil

    assert_equal 1, r.appointments.reload.size
    assert_equal 1, r.elections.reload.size

    r.update! years_on_the_board: 42

    assert_equal 0, r.appointments.reload.size
    assert_equal 2, r.elections.reload.size
    assert_equal 42,
        r.elections.includes(:annual_meeting).order('annual_meetings.start_at')[0].years
    assert_equal 2, r.elections.includes(:annual_meeting).order('annual_meetings.start_at')[1].years
  end
end
