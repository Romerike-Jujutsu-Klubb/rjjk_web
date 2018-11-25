# frozen_string_literal: true

require 'feature_test'

class UsersFeatureTest < FeatureTest
  setup { screenshot_section :users }

  def test_index
    screenshot_group :index
    visit_with_login users_path
    screenshot(:index)
  end

  def test_index_unauthorized
    screenshot_group :index_unauthorized
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
