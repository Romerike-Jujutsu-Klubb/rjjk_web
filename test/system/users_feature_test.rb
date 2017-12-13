# frozen_string_literal: true

require 'feature_test'

class UsersFeatureTest < FeatureTest
  def setup
    screenshot_section :users
  end

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
end
