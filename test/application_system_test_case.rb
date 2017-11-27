# frozen_string_literal: true

require 'test_helper'

class ApplicationSystemTestCase < ActionDispatch::SystemTestCase
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
  include Capybara::Screenshot::Diff

  def open_menu
    find('#navBtn').click
  end

  def click_menu(menu_item)
    open_menu
    click_link menu_item
  end
end
