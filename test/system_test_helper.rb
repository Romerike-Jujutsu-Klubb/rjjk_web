# frozen_string_literal: true

module SystemTestHelper
  def clear_cookies
    browser = Capybara.current_session.driver.browser
    if browser.respond_to?(:clear_cookies)
      # Rack::MockSession
      browser.clear_cookies
    elsif browser.respond_to?(:manage) && browser.manage.respond_to?(:delete_all_cookies)
      # Selenium::WebDriver
      browser.manage.delete_all_cookies
    else
      raise "Don't know how to clear cookies. Weird driver?"
    end
  end

  def visit_with_login(path, redirected_path: nil, user: :admin)
    uri = URI.parse(path)
    uri.query = [uri.query, 'key=' + users(user).security_token].compact.join('&')
    visit uri.to_s
    uri.fragment = nil
    assert_current_path redirected_path || uri.to_s
  end

  def login_and_visit(path, user = :admin, redirected_path: path)
    login(user)
    assert_current_path '/'
    visit path
    assert_current_path redirected_path
  end

  def login(user = :admin)
    visit '/login/password'
    fill_login_form user
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
        break if active.zero?

        sleep 0.01
      end
    end
  end

  def close_alerts
    all('.alert button.close').each(&:click)
    assert has_no_css?('.alert button.close')
  end

  def open_menu
    close_alerts
    find('#navBtn', wait: 30).click
  end

  def click_menu(menu_item)
    open_menu
    link = find(:link, menu_item)
    begin
      link.click
    rescue
      tries ||= 1
      raise "click menu failed (#{tries}): #{$ERROR_INFO}" if tries >= 7

      sleep 0.001
      tries += 1
      retry
    end
  end

  def select_from_chosen(item_text, options)
    field = find_field(options[:from], visible: false, disabled: :all)
    find("##{field[:id]}_chosen").click
    find("##{field[:id]}_chosen ul.chosen-results li", text: item_text).click
  end
end
