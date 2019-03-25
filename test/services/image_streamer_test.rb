# frozen_string_literal: true

require 'test_helper'

class ImageStreamerTest < ActiveSupport::TestCase
  test 'stream an image' do
    loaded_data = +''
    ImageStreamer.new(id(:one)).each { |data| loaded_data << data }
    assert_equal images(:one).content_data, loaded_data
  end
end
