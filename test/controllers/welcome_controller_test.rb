# frozen_string_literal: true

require 'test_helper'

class WelcomeControllerTest < ActionDispatch::IntegrationTest
  test 'get index as a parent' do
    login :neuer
    get root_path
  end
end
