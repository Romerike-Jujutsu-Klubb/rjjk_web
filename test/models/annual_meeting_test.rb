# frozen_string_literal: true

require 'test_helper'

class AnnualMeetingTest < ActiveSupport::TestCase
  test 'changing event type allows two event in the same year' do
    am1 = annual_meetings(:last)
    am2 = annual_meetings(:next)

    assert am1.valid?
    assert am2.valid?
    assert_equal AnnualMeeting, am2.class
    assert_equal 'AnnualMeeting', am2.type

    am2.start_at = '2013-03-01'
    assert_not am2.valid?
    assert_equal ['Dato og tid kan bare ha et årsmøte per år.'], am2.errors.full_messages

    am2.type = 'Event'
    assert_not am2.valid?

    am2.type = 'AnnualMeeting'
    assert_equal 'AnnualMeeting', am2.type

    am2_2 = am2.becomes(Event)
    assert_equal 'AnnualMeeting', am2_2.type
    assert_equal Event, am2_2.class
    assert am2_2.valid?

    am2_3 = am2.becomes!(Event)
    assert_nil am2_3.type
    assert_equal Event, am2_3.class
    assert am2_3.valid?

    am2_4 = am2.becomes!(Camp)
    assert_equal 'Camp', am2_4.type
    assert_equal Camp, am2_4.class
    assert am2_4.valid?

    assert_not am2.valid?
  end
end
