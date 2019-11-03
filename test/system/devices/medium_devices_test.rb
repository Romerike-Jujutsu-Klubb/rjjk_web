# frozen_string_literal: true

require_relative 'device_system_test'

class MediumDeviceTest < ApplicationSystemTestCase
  include DeviceSystemTest
  use_device device_metrics: { width: 640, height: 480, pixelRatio: 1, touch: true },
      window_size: [640, 480], menu_logo_area: [308, 73, 332, 102],
      logo_area: [200, 0, 365, 170]
end
