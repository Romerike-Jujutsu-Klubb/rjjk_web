# frozen_string_literal: true

require "#{File.dirname(__FILE__)}/../test_helper"

class MemberTest < ActiveSupport::TestCase
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
      members(:lars).update! image_file: Image.new
    end
  end

  test 'next_rank' do
    assert_equal ['sandan', 'shodan', '11. mon', '5. kyu', '5. kyu', '5. kyu'],
        Member.order(:joined_on).all.map(&:next_rank).map(&:name)
  end

  test 'emails' do
    assert_equal [
      ['lars@example.com'],
      ['leftie@example.com'],
      ['lise@example.com', 'sebastian@example.com', 'uwe@example.com'],
      ['neuer@example.com', 'newbie@example.com'],
      ['oldie@example.com'],
      ['uwe@example.com'],
    ], Member.order(:id).map(&:emails)
  end
end
