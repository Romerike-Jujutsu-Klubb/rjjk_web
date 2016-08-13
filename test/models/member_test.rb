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
  end

  test 'next_rank' do
    assert_equal ['sandan', 'shodan', '11. mon', '5. kyu'],
        Member.order(:joined_on).all.map(&:next_rank).map(&:name)
  end

  test 'passive?' do
    assert_equal false, members(:lars).passive?
    assert_equal false, members(:newbie).passive?
    assert_equal true, members(:sebastian).passive?
    assert_equal false, members(:uwe).passive?
  end

  test 'passive? preloaded attendances for group' do
    members = Member.includes(:attendances).order(:first_name)
    assert_equal [false, false, true, false], members.map { |m| m.passive?(Date.today, groups(:voksne)) }
  end

  test 'passive? preloaded recent_attendances' do
    members = Member.includes(:recent_attendances).order(:first_name)
    assert_equal [false, false, true, false], members.map { |m| m.passive?(Date.today, groups(:voksne)) }
  end
end
