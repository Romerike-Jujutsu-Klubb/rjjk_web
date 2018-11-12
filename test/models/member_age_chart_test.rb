# frozen_string_literal: true

require 'test_helper'

class MemberAgeChartTest < ActiveSupport::TestCase
  def test_chart
    MemberAgeChart.data_set
  end
end
