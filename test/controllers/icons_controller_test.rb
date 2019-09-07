# frozen_string_literal: true

require 'integration_test'

class IconsControllerTest < IntegrationTest
  setup {FileUtils.rm_rf "#{Rails.root}/public/icon" }

  test 'should serve an icon' do
    get '/icon/32.png'
    assert_response :success
  end

  test 'should serve a notification_icon' do
    get '/icon/notification.png'
    assert_response :success
  end
end
