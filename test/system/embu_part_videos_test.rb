# frozen_string_literal: true

require 'application_system_test_case'

class EmbuPartVideosTest < ApplicationSystemTestCase
  setup do
    @embu_part_video = embu_part_videos(:one)
  end

  test 'visiting the index' do
    visit embu_part_videos_path
    assert_selector 'h1', text: 'Listing embu_part_videos'
  end

  test 'creating a Embu part video' do
    visit embu_part_videos_path
    click_on 'New Embu part video'

    fill_in 'Comment', with: @embu_part_video.comment
    fill_in 'Embu part', with: @embu_part_video.embu_part_id
    fill_in 'Image', with: @embu_part_video.image_id
    click_on 'Lag Embu part video'

    assert_text 'Embu part video was successfully created'
    click_on 'Back'
  end

  test 'updating a Embu part video' do
    visit embu_part_videos_path
    click_on 'Edit', match: :first

    fill_in 'Comment', with: @embu_part_video.comment
    fill_in 'Embu part', with: @embu_part_video.embu_part_id
    fill_in 'Image', with: @embu_part_video.image_id
    click_on 'Oppdater Embu part video'

    assert_text 'Embu part video was successfully updated'
    click_on 'Back'
  end

  test 'destroying a Embu part video' do
    visit embu_part_videos_path
    page.accept_confirm do
      click_on 'Destroy', match: :first
    end

    assert_text 'Embu part video was successfully destroyed'
  end
end
