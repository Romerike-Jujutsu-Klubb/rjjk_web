# frozen_string_literal: true

require 'feature_test'

class NextPracticeAttendanceTest < FeatureTest
  setup { login_and_visit '/' }

  def test_announce_attendance
    assert_gallery_image_is_loaded
    screenshot('next_practice/initial')
    find('#next_practice i.fa-thumbs-down').click
    assert_gallery_image_is_loaded
    screenshot('next_practice/absence')
    find('#next_practice i.fa-thumbs-up').click
    assert_gallery_image_is_loaded
    screenshot('next_practice/will_attend')
  end
end
