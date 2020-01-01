# frozen_string_literal: true

require 'application_system_test_case'

class ApplicationImageSequencesTest < ApplicationSystemTestCase
  setup do
    @application_image_sequence = application_image_sequences(:one)
    login
  end

  test 'visiting the index' do
    visit application_image_sequences_url
    assert_selector 'h1', text: 'Application Image Sequences'
  end

  test 'creating a Application image sequence' do
    visit application_image_sequences_url
    click_on 'New Application image sequence'

    fill_in 'Position', with: @application_image_sequence.position + 1
    fill_in 'Technique application', with: @application_image_sequence.technique_application_id
    fill_in 'Tittel', with: @application_image_sequence.title
    click_on 'Lag Application image sequence'

    assert_text 'Application image sequence was successfully created'
    click_on 'Back'
  end

  test 'updating a Application image sequence' do
    visit application_image_sequences_url
    click_on 'Edit', match: :first

    fill_in 'Position', with: @application_image_sequence.position
    fill_in 'Technique application', with: @application_image_sequence.technique_application_id
    fill_in 'Tittel', with: @application_image_sequence.title
    click_on 'Oppdater Application image sequence'

    assert_text 'Application image sequence was successfully updated'
    click_on 'Back'
  end

  test 'destroying a Application image sequence' do
    visit application_image_sequences_url
    page.accept_confirm do
      click_on 'Destroy', match: :first
    end

    assert_text 'Application image sequence was successfully destroyed'
  end
end
