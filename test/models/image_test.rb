# frozen_string_literal: true

require 'test_helper'

class ImageTest < ActiveSupport::TestCase
  def test_create
    login
    Image.create! name: 'new file', content_type: 'image/png', content_data: 'qwerty', content_length: 6
  end

  test 'valid fixtures' do
    assert Image.all.all?(&:valid?), -> do
      invalid_image = Image.all.find(&:invalid?)
      "Invalid image: #{invalid_image.errors.full_messages}, #{invalid_image.inspect}"
    end
  end
end
