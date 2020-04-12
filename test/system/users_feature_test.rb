# frozen_string_literal: true

require 'application_system_test_case'

class UsersFeatureTest < ApplicationSystemTestCase
  def test_index
    visit_with_login users_path
    screenshot(:index)
  end

  def test_index_unauthorized
    visit users_path
    screenshot(:index)
  end

  def test_send_login_link
    visit_with_login user_path(id(:lars))
    click_link 'Send e-post med login link'
    assert_current_path user_path(id(:lars))
    find '.alert-info p', text: 'En e-post med innloggingslenke er sendt til lars@example.com.'
  end
end
