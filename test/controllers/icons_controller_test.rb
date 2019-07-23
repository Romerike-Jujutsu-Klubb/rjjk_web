# frozen_string_literal: true

require 'integration_test'

class IconsControllerTest < IntegrationTest
  test 'should serve an icon' do
    get '/icon/32.png'
  end

  test 'should serve a notification_icon' do
    get '/icon/notification.png'
  end
end
