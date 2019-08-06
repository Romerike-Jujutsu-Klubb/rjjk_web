# frozen_string_literal: true

require 'test_helper'

class GroupSemesterTest < ActiveSupport::TestCase
  test 'practices' do
    assert_equal([[], [], [327_850_042, 176_408_974], [], []],
        GroupSemester.order(:id).to_a.map(&:practices).map(&:to_a).map { |a| a.sort_by(&:date).map(&:id) })
  end
end
