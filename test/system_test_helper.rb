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
    uri.query = [uri.query, "key=#{users(user).generate_security_token(:login)}"].compact.join('&')
    visit uri.to_s
    uri.fragment = nil
    assert_current_path redirected_path || uri.to_s
  end

  def login(user = :uwe)
    visit_with_login '/', user: user
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

  def open_menu_section(section_title)
    open_menu
    section = find('#main-menu > h1', text: section_title)
    section.click
    find(section['data-target'])
  end

  def click_menu(menu_item, section:)
    section = open_menu_section(section)
    link = section.find(:link, menu_item)
    with_retries(label: 'click menu') { link.click }
  end

  def select_from_chosen(item_text, options)
    field = find_field(options[:from], visible: false, disabled: :all)
    find("##{field[:id]}_chosen").click
    find("##{field[:id]}_chosen ul.chosen-results li", text: item_text).click
  end
end
