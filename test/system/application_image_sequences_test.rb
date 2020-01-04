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
    visit edit_technique_application_path(@application_image_sequence.technique_application_id)
    click_on 'Legg til bildeserie'

    select @application_image_sequence.technique_application.name, from: 'Technique application'
    fill_in 'Tittel', with: 'A new sequence'
    click_on 'Lagre'

    assert_text 'Application image sequence was successfully created'
    click_on 'A new sequence'
  end

  test 'updating a Application image sequence' do
    visit edit_technique_application_path(@application_image_sequence.technique_application_id)
    click_on 'Alternative ending'

    select @application_image_sequence.technique_application.name, from: 'Technique application'
    fill_in 'Tittel', with: 'The changed series'
    click_on 'Lagre'

    assert_text 'Application image sequence was successfully updated'

    click_on 'The changed series'
  end

  test 'destroying a Application image sequence' do
    visit application_image_sequences_url
    page.accept_confirm do
      click_on 'Destroy', match: :first
    end

    assert_text 'Application image sequence was successfully destroyed'
  end
end
