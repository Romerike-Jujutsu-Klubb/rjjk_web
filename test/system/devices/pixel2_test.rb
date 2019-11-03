# frozen_string_literal: true

require_relative 'device_system_test'

class Pixel2Test < ApplicationSystemTestCase
  include DeviceSystemTest
  use_device device_name: 'Pixel 2', window_size: [1079, 1919].freeze, menu_logo_area: [500, 188, 575, 275],
      logo_area: [200, 0, 365, 170]
end
