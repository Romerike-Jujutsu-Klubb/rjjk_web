# frozen_string_literal: true

require 'test_helper'

class ApplicationHelperTest < ActiveSupport::TestCase
  include ApplicationHelper

  test 'month_name 12' do
    I18n.with_locale(:nb) { assert_equal 'desember', month_name(12) }
    I18n.with_locale(:en) { assert_equal 'December', month_name(12) }
  end
end
