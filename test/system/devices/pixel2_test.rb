# frozen_string_literal: true

require_relative 'device_system_test'

class Pixel2Test < ApplicationSystemTestCase
  include DeviceSystemTest
  use_device device_name: 'Pixel 2', menu_logo_area: [500, 188, 575, 275], logo_area: [200, 0, 365, 170],
      public_menu_btn_area: [471, 79, 510, 192], public_menu_logo_area: nil
end
