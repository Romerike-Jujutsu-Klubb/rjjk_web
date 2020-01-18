# frozen_string_literal: true

require 'test_helper'

class WelcomeControllerTest < ActionDispatch::IntegrationTest
  test 'get index as a parent' do
    login :neuer
    get root_path
  end

  test 'get index without upcoming ecvent' do
    events(:one).destroy!
    get root_path
  end

  test 'get index as an admin' do
    login :uwe
    get root_path
  end
end
