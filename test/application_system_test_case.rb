# frozen_string_literal: true

require 'test_helper'
require 'system_test_helper'

class ApplicationSystemTestCase < ActionDispatch::SystemTestCase
  include Capybara::Screenshot::Diff
  include SystemTestHelper

  driven_by :selenium, using: :chrome, screen_size: [1024, 768], options: {
    desired_capabilities: {
      chromeOptions: {
        args: %w[headless disable-gpu force-device-scale-factor=1],
        prefs: {
          'modifyheaders.headers.name' => 'Accept-Language',
          'modifyheaders.headers.value' => 'nb,en',
        },
      },
    },
  }
end
