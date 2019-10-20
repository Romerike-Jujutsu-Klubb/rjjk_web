# frozen_string_literal: true

require File.dirname(__FILE__) + '/../test_helper'

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

  test 'absent?' do
    assert_equal false, members(:lars).absent?
    assert_equal false, members(:newbie).absent?
    assert_equal true, members(:sebastian).absent?
    assert_equal false, members(:uwe).absent?
  end

  test 'absent? preloaded attendances for group' do
    members = Member.includes(:attendances).order(:id)
    assert_equal [false, true, true, false, false, false],
        (members.map { |m| m.absent?(Date.current, groups(:voksne)) })
  end

  test 'absent? preloaded recent_attendances' do
    members = Member.includes(:recent_attendances).order(:id)
    assert_equal [false, true, true, false, false, false],
        (members.map { |m| m.absent?(Date.current, groups(:voksne)) })
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
