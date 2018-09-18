# frozen_string_literal: true

module SystemTestHelper
  def visit_with_login(path, redirected_path: path, user: :admin)
    visit path
    if current_path == '/login'
      click_on 'logge på med passord'
      assert_current_path login_password_path
      fill_login_form(user)
    end
    assert_current_path redirected_path
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

  def open_menu
    find('#navBtn').click
  end

  def click_menu(menu_item)
    open_menu
    click_link menu_item
  end
end
