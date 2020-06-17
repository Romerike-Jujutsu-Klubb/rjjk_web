# frozen_string_literal: true

require File.dirname(__FILE__) + '/../test_helper'

class GroupTest < ActiveSupport::TestCase
  test 'suggested_graduation_date' do
    assert_equal [Date.parse('2013-12-12'), nil, Date.parse('2013-12-10'), Date.parse('2013-12-10'), nil, nil],
        Group.order(:from_age, :to_age, :id).map(&:suggested_graduation_date)
  end

  test 'suggested_graduation_date spring 2019' do
    new_year = Date.parse('2019-01-01')
    assert_equal(
        [Date.parse('2019-06-13'), nil, Date.parse('2019-06-11'), Date.parse('2019-06-11'), nil, nil],
        Group.order(:from_age, :to_age, :id).map { |g| g.suggested_graduation_date(new_year) }
      )
  end
end
