require 'capybara/rails'
require 'image_compare'

# Transactional fixtures do not work with Selenium tests, because Capybara
# uses a separate server thread, which the transactions would be hidden
# from. We hence use DatabaseCleaner to truncate our test database.
DatabaseCleaner.strategy = :truncation

class ActionDispatch::IntegrationTest
  WINDOW_SIZE = [1024, 768]
  SCREENSHOT_DIR = 'doc/screenshots'
  SCREENSHOT_DIR_ABS = "#{Rails.root}/#{SCREENSHOT_DIR}"

  include Capybara::DSL

  Capybara.default_driver = :selenium

  self.use_transactional_fixtures = false
  TEST_START = Time.now.change(sec: 0)

  setup do
    Capybara.current_session.driver.browser.manage.window.resize_to(*WINDOW_SIZE)
    Timecop.travel TEST_START
  end

  teardown do
    DatabaseCleaner.clean       # Truncate the database
    Capybara.reset_sessions!    # Forget the (simulated) browser state
    Capybara.use_default_driver # Revert Capybara.current_driver to Capybara.default_driver
    fail(@test_screenshot_errors.join("\n")) if @test_screenshot_errors
  end

  def screenshot(name)
    return unless Capybara.current_session.driver.browser.manage.window.size == Selenium::WebDriver::Dimension.new(*WINDOW_SIZE)
    file_name = "#{SCREENSHOT_DIR_ABS}/#{name}.png"
    svn_file_name = "#{SCREENSHOT_DIR_ABS}/.svn/text-base/#{name}.png.svn-base"
    org_name = "#{SCREENSHOT_DIR_ABS}/#{name}_0.png~"
    new_name = "#{SCREENSHOT_DIR_ABS}/#{name}_1.png~"
    unless File.exists?(svn_file_name)
      svn_info = `svn info #{file_name}`
      if svn_info.blank?
        FileUtils.mkdir_p File.dirname(org_name)
        # http://www.akikoskinen.info/image-diffs-with-git/
        puts `git show HEAD~0:#{SCREENSHOT_DIR}/#{name}.png > #{org_name}`
        FileUtils.rm_f org_name if File.size(org_name) == 0
        svn_file_name = org_name
      else
        wc_root = svn_info.slice /(?<=^Working Copy Root Path: ).*$/
        checksum = svn_info.slice /(?<=^Checksum: ).*$/
        svn_file_name = "#{wc_root}/.svn/pristine/#{checksum[0..1]}/#{checksum}.svn-base"
      end
    end
    old_file_size = nil
    loop do
      page.save_screenshot(file_name)
      break if old_file_size == File.size(file_name)
      old_file_size = File.size(file_name)
      sleep 0.5
    end
    if ImageCompare.compare(file_name, svn_file_name)
      (@test_screenshot_errors ||= []) <<
          "Screenshot does not match for #{name.inspect}\n#{file_name}\n#{org_name}\n#{new_name}\n#{caller[0]}"
    end
  end
end

module Capybara
  self.default_wait_time = 15
  module Node
    class Element
      def hover
        @session.driver.browser.action.move_to(self.native).perform
      end
    end
  end
end
