require 'minitest/rails/capybara'
require 'image_compare'
require 'capybara/poltergeist'

# Transactional fixtures do not work with Selenium tests, because Capybara
# uses a separate server thread, which the transactions would be hidden
# from. We hence use DatabaseCleaner to truncate our test database.
# DatabaseCleaner.strategy = :transaction

class ActionDispatch::IntegrationTest
  include Capybara::DSL

  Capybara.default_driver = rand(10) == 0 ? :selenium : :poltergeist

  WINDOW_SIZE = [1024, 768]
  SCREENSHOT_DIR = 'doc/screenshots'
  SCREENSHOT_DIR_ABS = "#{Rails.root}/#{SCREENSHOT_DIR}/#{Capybara.default_driver}"

  Capybara.default_max_wait_time = 30
  self.use_transactional_fixtures = false

  setup do
    @screenshot_abs_dir = SCREENSHOT_DIR_ABS
    if Capybara.default_driver == :selenium
      Capybara.current_session.driver.browser.manage.window.resize_to(*WINDOW_SIZE)
    else
      page.driver.resize(*WINDOW_SIZE)
    end
    Timecop.travel TEST_TIME
  end

  teardown do
    DatabaseCleaner.clean # Truncate the database
    Capybara.reset_sessions! # Forget the (simulated) browser state
    fail(@test_screenshot_errors.join("\n")) if @test_screenshot_errors
  end

  def screenshot_group(name)
    @screenshot_abs_dir = "#{SCREENSHOT_DIR_ABS}/#{name}"
    @screenshot_dir = "#{SCREENSHOT_DIR}/#{name}"
    @screenshot_counter = 0
    FileUtils.rm_rf @screenshot_abs_dir if name.present?
  end

  def screenshot(name)
    if @screenshot_counter
      name = "#{'%02i' % @screenshot_counter}_#{name}"
      @screenshot_counter += 1
    end
    if Capybara.default_driver == :selenium
      return unless Capybara.current_session.driver.browser.manage.window.size == Selenium::WebDriver::Dimension.new(*WINDOW_SIZE)
    else
      return unless Capybara.current_session.driver.client.window_size == WINDOW_SIZE
    end
    file_name = "#{@screenshot_abs_dir}/#{name}.png"
    svn_file_name = "#{@screenshot_abs_dir}/.svn/text-base/#{name}.png.svn-base"
    org_name = "#{@screenshot_abs_dir}/#{name}_0.png~"
    new_name = "#{@screenshot_abs_dir}/#{name}_1.png~"
    FileUtils.mkdir_p File.dirname(org_name)
    unless File.exists?(svn_file_name)
      svn_info = `svn info #{file_name}`
      if svn_info.blank?
        # http://www.akikoskinen.info/image-diffs-with-git/
        puts `git show HEAD~0:#{@screenshot_dir}/#{name}.png > #{org_name}`
        if File.size(org_name) == 0
          FileUtils.rm_f org_name
        else
          svn_file_name = org_name
        end
      else
        wc_root = svn_info.slice /(?<=Working Copy Root Path: ).*$/
        checksum = svn_info.slice /(?<=Checksum: ).*$/
        if checksum
          svn_file_name = "#{wc_root}/.svn/pristine/#{checksum[0..1]}/#{checksum}.svn-base"
        end
      end
    end
    assert_images_loaded
    take_stable_screeenshot(file_name)
    return unless File.exist?(svn_file_name)
    if ImageCompare.compare(file_name, svn_file_name, WINDOW_SIZE)
      (@test_screenshot_errors ||= []) <<
          "Screenshot does not match for #{name.inspect}\n#{file_name}\n#{org_name}\n#{new_name}\n#{caller[0]}"
    end
  end

  def take_stable_screeenshot(file_name)
    old_file_size = nil
    loop do
      page.save_screenshot(file_name)
      break if old_file_size == File.size(file_name)
      old_file_size = File.size(file_name)
      sleep 0.25
    end
  end

  def visit_with_login(path, redirected_path: path, user: :admin)
    visit path
    fill_login_form(user) if current_path == '/user/login'
    assert_current_path redirected_path
  end

  def login_and_visit(path, user = :admin)
    visit '/user/login'
    fill_login_form user
    visit path
  end

  def fill_login_form(user)
    fill_in 'user_login', with: user
    fill_in 'user_password', with: 'atest'
    click_button 'Logg inn'
  end

  def wait_for_ajax
    Timeout.timeout(Capybara.default_max_wait_time) do
      loop do
        active = page.evaluate_script('jQuery.active')
        break if active == 0
        sleep 0.01
      end
    end
  end

  def assert_current_path(path)
    start = Time.now
    sleep 0.1 while (Time.now - start) < Capybara.default_max_wait_time && current_path != path
    assert_equal path, current_path
  end

  IMAGE_WAIT_SCRIPT = <<EOF
function pending_image() {
  var images = document.images;
  for (var i = 0; i < images.length; i++) {
    if (!images[i].complete) {
        return images[i].src;
    }
  }
  return false;
}()
EOF

  def assert_images_loaded(timeout: Capybara.default_max_wait_time)
    start = Time.now
    loop do
      pending_image = evaluate_script IMAGE_WAIT_SCRIPT
      break unless pending_image
      assert (Time.now - start) < timeout,
          "Image not loaded after #{timeout}s: #{pending_image.inspect}"
      sleep 0.1
    end
  end
end
