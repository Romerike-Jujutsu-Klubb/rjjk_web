# frozen_string_literal: true

require 'test_helper'

class ImageTest < ActiveSupport::TestCase
  def test_create
    login
    Image.create! name: 'new file', content_type: 'image/png', content_data: 'qwerty'
  end
end
