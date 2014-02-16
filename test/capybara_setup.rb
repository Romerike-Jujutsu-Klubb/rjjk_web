require 'capybara/rails'
require 'image_compare'

# Transactional fixtures do not work with Selenium tests, because Capybara
# uses a separate server thread, which the transactions would be hidden
# from. We hence use DatabaseCleaner to truncate our test database.
DatabaseCleaner.strategy = :truncation

class ActionDispatch::IntegrationTest
  SCREENSHOT_DIR = 'doc/screenshots'
  SCREENSHOT_DIR_ABS = "#{Rails.root}/#{SCREENSHOT_DIR}"

  include Capybara::DSL

  Capybara.default_driver = :selenium

  self.use_transactional_fixtures = false

  setup do
    Capybara.current_session.driver.browser.manage.window.resize_to(1024, 768)
    Timecop.travel
  end

  teardown do
    DatabaseCleaner.clean       # Truncate the database
    Capybara.reset_sessions!    # Forget the (simulated) browser state
    Capybara.use_default_driver # Revert Capybara.current_driver to Capybara.default_driver
  end

  def screenshot(name)
    return unless Capybara.current_session.driver.browser.manage.window.size == Selenium::WebDriver::Dimension.new(1024, 768)
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
      # fail("Screenshot does not match for #{name.inspect}\n#{file_name}\n#{org_name}\n#{new_name}")
    end
  end
end
