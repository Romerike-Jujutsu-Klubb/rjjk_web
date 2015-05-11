require File.dirname(__FILE__) + '/../test_helper'

class MemberTest < ActiveSupport::TestCase
  fixtures :members

  class Image
    def original_filename
      'My Image'
    end

    def content_type
      'image/png'
    end

    def read
      'Image Content'
    end
  end

  def test_update_image
    VCR.use_cassette 'GoogleMaps Lars' do
      members(:lars).update_attributes image_file: Image.new
    end
  rescue SocketError
  end
end
