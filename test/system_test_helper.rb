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

  def visit_with_login(path, redirected_path: nil, user: :uwe)
    uri = URI.parse(path)
    uri.query = [uri.query, "key=#{users(user).security_token}"].compact.join('&')
    visit uri.to_s
    uri.fragment = nil
    assert_current_path redirected_path || uri.to_s
  end

  def login_and_visit(path, user = :uwe, redirected_path: path)
    login(user)
    assert_current_path '/'
    visit path
    assert_current_path redirected_path
  end

  def login(user = :uwe)
    visit '/login/password'
    fill_login_form user
  end

  def fill_login_form(user)
    fill_in 'user_login', with: user
    fill_in 'user_password', with: 'atest'
    click_button 'Logg inn'
  end

  def wait_for_ajax
    with_retries { assert page.evaluate_script('jQuery.active').zero? }
  end

  def all(*args, **opts)
    super(*args, **{ wait: false }.merge(opts))
  end

  def close_alerts
    all('.alert button.close').each(&:click)
    assert has_no_css?('.alert button.close')
  end

  def open_menu
    close_alerts
    find('#navBtn', wait: 30).click
  end

  def click_menu(menu_item, section: nil)
    open_menu
    find('#main-menu > h1', text: section).click if section
    link = find(:link, menu_item)
    with_retries(label: 'click menu') { link.click }
  end

  def select_from_chosen(item_text, options)
    field = find_field(options[:from], visible: false, disabled: :all)
    find("##{field[:id]}_chosen").click
    find("##{field[:id]}_chosen ul.chosen-results li", text: item_text).click
  end
end
