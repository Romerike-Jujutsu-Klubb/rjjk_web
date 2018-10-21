# frozen_string_literal: true

require 'test_helper'
require 'system_test_helper'

class ApplicationSystemTestCase < ActionDispatch::SystemTestCase
  include Capybara::Screenshot::Diff
  include SystemTestHelper

  Capybara.register_driver :chrome do |app|
    # options explained https://peter.sh/experiments/chromium-command-line-switches/
    # no-sandbox
    #   because the user namespace is not enabled in the container by default
    # headless
    #   run w/o actually launching gui
    # disable-gpu
    #   Disables graphics processing unit(GPU) hardware acceleration
    # window-size
    #   sets default window size in case the smaller default size is not enough
    #   we do not want max either, so this is a good compromise
    # use-fake-ui-for-media-stream
    #   Avoid dialogs to grant permission to use the camera
    capabilities = Selenium::WebDriver::Remote::Capabilities.chrome(chromeOptions: {
      args: %w[no-sandbox headless disable-gpu window-size=1024,768 use-fake-ui-for-media-stream],
      prefs: {
        'modifyheaders.headers.name' => 'Accept-Language',
        'modifyheaders.headers.value' => 'nb,en',
      },
    })
    Capybara::Selenium::Driver.new(app, browser: :chrome, desired_capabilities: capabilities)
  end
  driven_by :chrome
  Capybara.server = :puma, { Silent: true }
end
