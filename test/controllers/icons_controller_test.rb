# frozen_string_literal: true

require 'integration_test'

class IconsControllerTest < IntegrationTest
  test 'should serve an icon' do
    get '/icon/32.png'
  end
end
