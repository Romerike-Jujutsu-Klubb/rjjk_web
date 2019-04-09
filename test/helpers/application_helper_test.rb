# frozen_string_literal: true

require 'test_helper'

class ApplicationHelperTest < ActiveSupport::TestCase
  include ApplicationHelper

  test 'month_name 12' do
    assert_equal 'desember', month_name(12)
  end
end
