# frozen_string_literal: true

require 'test_helper'

class AttendanceHistoryGraphTest < ActiveSupport::TestCase
  test('month_per_year_chart_data') do
    AttendanceHistoryGraph.month_per_year_chart_data(1)
  end

  test('month_chart_data') do
    AttendanceHistoryGraph.month_chart_data(2013, 1)
  end
end
