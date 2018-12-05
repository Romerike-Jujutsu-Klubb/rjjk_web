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
  Capybara::Screenshot.hide_caret = true
  Capybara::Screenshot.stability_time_limit = 0.1

  Capybara.default_driver = :chrome # :selenium, :chrome
  Capybara::Screenshot::Diff.color_distance_limit = 14.5 if Capybara.default_driver == :chrome
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
