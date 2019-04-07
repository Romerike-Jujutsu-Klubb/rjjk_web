# frozen_string_literal: true

require 'test_helper'

class ApplicationHelperTest < ActiveSupport::TestCase
  include ApplicationHelper
  # include Rails.application.routes.url_helpers

  test 'month_name 12' do
    assert_equal 'Desember', month_name(12)
  end
end
