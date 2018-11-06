# frozen_string_literal: true

require 'integration_test'

class AttendanceNotificationsControllerTest < IntegrationTest
  setup { login }

  test 'index' do
    ENV['VAPID_PUBLIC_KEY'] = 'aGVp'
    get attendance_notifications_path
  end

  test 'subscribe' do
    post subscribe_attendance_notifications_path, params: {
      subscription: { endpoint: 3, keys: { p256dh: 2, auth: 1 } },
    }
  end

  test 'push' do
    post push_attendance_notifications_path
  end
end
