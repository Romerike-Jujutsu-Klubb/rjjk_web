# frozen_string_literal: true
require File.dirname(__FILE__) + '/../test_helper'

class GroupScheduleTest < ActiveSupport::TestCase
  def test_next_practice_end_of_year
    schedule = group_schedules(:voksne_tuesday)
    next_practice = schedule.next_practice(Time.zone.parse('2013-12-24 23:59'))
    assert_equal Date.parse('2013-12-31'), next_practice.date
  end
end
