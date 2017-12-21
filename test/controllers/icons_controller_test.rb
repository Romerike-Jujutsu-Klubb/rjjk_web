# frozen_string_literal: true

require 'integration_test'

class IconsControllerTest < ActionDispatch::IntegrationTest
  test 'should serve an icon' do
    get '/icon/32.png'
  end
end
