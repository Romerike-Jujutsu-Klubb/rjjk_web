# frozen_string_literal: true

require 'test_helper'
require 'minitest/rails/capybara'
require 'capybara/screenshot/diff'
require 'system_test_helper'

class FeatureTest < ActionDispatch::IntegrationTest
  include Capybara::Screenshot::Diff
  include SystemTestHelper

  Capybara::Screenshot.add_driver_path = true
  Capybara::Screenshot.window_size = WINDOW_SIZE
  Capybara::Screenshot.enabled = ENV['TRAVIS'].blank?
  Capybara::Screenshot.stability_time_limit = 0.5

  Capybara.default_driver = :chrome # :selenium, :chrome
  if Capybara.default_driver == :chrome
    Capybara::Screenshot::Diff.color_distance_limit = 14.5
    Capybara::Screenshot::Diff.area_size_limit = 18
  end
  Capybara.default_max_wait_time = 30
end

if Capybara.default_driver == :chrome
  module ClickScroller
    def click
      script = "document.evaluate('#{path}', document, null, XPathResult.FIRST_ORDERED_NODE_TYPE, null).singleNodeValue.scrollIntoViewIfNeeded()" # rubocop: disable Metrics/LineLength
      driver.execute_script script
      super
    end
  end
  Capybara::Selenium::Node.prepend ClickScroller
end
