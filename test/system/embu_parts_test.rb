# frozen_string_literal: true

require 'application_system_test_case'

class EmbuPartsTest < ApplicationSystemTestCase
  setup do
    @embu_part = embu_parts(:one)
  end

  test 'visiting the index' do
    visit embu_parts_path
    assert_selector 'h1', text: 'Listing embu_parts'
  end

  test 'creating a Embu part' do
    visit embu_parts_path
    click_on 'New Embu part'

    fill_in 'Description', with: @embu_part.description
    fill_in 'embu_part_embu_id', with: @embu_part.embu_id
    fill_in 'Position', with: @embu_part.position
    click_on 'Lag Embu part'

    assert_text 'Embu part was successfully created'
    click_on 'Back'
  end

  test 'updating a Embu part' do
    visit embu_parts_path
    click_on 'Edit', match: :first

    fill_in 'Description', with: @embu_part.description
    fill_in 'Embu', with: @embu_part.embu_id
    fill_in 'Position', with: @embu_part.position
    click_on 'Oppdater Embu part'

    assert_text 'Embu part was successfully updated'
    click_on 'Back'
  end

  test 'destroying a Embu part' do
    visit embu_parts_path
    page.accept_confirm do
      click_on 'Destroy', match: :first
    end

    assert_text 'Embu part was successfully destroyed'
  end
end
