# frozen_string_literal: true

require 'application_system_test_case'

class ApplicationVideosTest < ApplicationSystemTestCase
  setup do
    login
    @application_video = application_videos(:one)
  end

  test 'visiting the index' do
    visit application_videos_url
    assert_selector 'h1', text: 'Application Videos'
  end

  test 'creating an application video' do
    visit ranks_path
    find('a', text: 'Kei Wa Ryu').click
    click_on '1. kyu brunt belte'
    click_on 'Forsvar mot dobbelt hårtak med kneing'
    click_on 'Legg til film'

    find('#application_video_image_attributes_file', visible: false)
        .set("#{Rails.root}/test/fixtures/files/tiny.png")
    sleep 0.1

    click_on 'Lagre'

    assert_text 'Application video was successfully created'
    click_on 'Back'
  end

  test 'updating an application video' do
    # visit application_videos_url
    # click_on 'Edit', match: :first
    #
    # fill_in 'Image', with: @application_video.image_id
    # fill_in 'Technique application', with: @application_video.technique_application_id
    # click_on 'Update Application video'
    #
    # assert_text 'Application video was successfully updated'
    # click_on 'Back'
  end

  test 'destroying an application video' do
    visit application_videos_url
    page.accept_confirm do
      click_on 'Destroy', match: :first
    end

    assert_text 'Application video was successfully destroyed'
  end
end
