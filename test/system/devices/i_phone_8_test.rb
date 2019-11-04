# frozen_string_literal: true

require_relative 'device_system_test'

class IPhone8Test < ApplicationSystemTestCase
  include DeviceSystemTest
  use_device device_name: 'iPhone 8', menu_logo_area: [308, 73, 332, 102], logo_area: [200, 0, 365, 170]
end
