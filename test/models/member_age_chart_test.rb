# frozen_string_literal: true

require 'test_helper'

class MemberAgeChartTest < ActiveSupport::TestCase
  def test_chart
    Rails.cache.delete('member_age_chart_data/2013-10-17_16:46:00.000000000')
    assert_equal 2, MemberAgeChart.data_set.size
    assert_equal [
      {
        name: 'Totalt',
        data: [['0..5', 0], ['6..9', 0], ['10..14', 0], ['15..19', 0], ['20..24', 1], ['25..29', 0],
               ['30..39', 0], ['40..49', 3], ['50..50', 0]],
        color: :black,
      }, {
        name: 'Betalende',
        data: [['0..5', 0], ['6..9', 0], ['10..14', 0], ['15..19', 0], ['20..24', 0], ['25..29', 0],
               ['30..39', 0], ['40..49', 0], ['50..50', 0]],
        color: :red,
      }, {
        name: 'Aktive',
        data: [['0..5', 0], ['6..9', 0], ['10..14', 0], ['15..19', 0], ['20..24', 1], ['25..29', 0],
               ['30..39', 0], ['40..49', 3], ['50..50', 0]],
        color: :green,
      }
    ], MemberAgeChart.data_set[1]
  end
end
