# frozen_string_literal: true

require_relative 'device_system_test'

class MediumDeviceTest < ApplicationSystemTestCase
  include DeviceSystemTest
  use_device device_metrics: { width: 640, height: 480, pixelRatio: 1, touch: true },
      menu_logo_area: [20, 16, 23, 41], logo_area: [200, 0, 365, 170], public_menu_btn_area: nil,
      public_menu_logo_area: [308, 73, 332, 102]
end
