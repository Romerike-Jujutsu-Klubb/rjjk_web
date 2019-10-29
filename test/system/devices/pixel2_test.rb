# frozen_string_literal: true

require_relative 'device_system_test'

class Pixel2Test < ApplicationSystemTestCase
  include DeviceSystemTest
  use_device 'Pixel 2', window_size: [1079, 1919].freeze
end
