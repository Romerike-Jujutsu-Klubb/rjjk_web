# frozen_string_literal: true

require 'application_system_test_case'

class FrontPageSectionsTest < ApplicationSystemTestCase
  setup do
    @front_page_section = front_page_sections(:one)
    login
  end

  test 'visiting the index' do
    visit front_page_sections_url
    assert_selector 'h1', text: 'Seksjoner på forsiden'
  end

  test 'creating a front page section' do
    visit front_page_sections_url
    click_on 'Ny seksjon'

    fill_in 'front_page_section_button_text', with: @front_page_section.button_text
    select_from_chosen @front_page_section.image.name, from: 'Bilde'
    select_from_chosen @front_page_section.information_page.title, from: 'Informasjonsside'
    fill_in 'Undertittel', with: @front_page_section.subtitle
    fill_in 'Tittel', with: @front_page_section.title
    click_on 'Lag Front page section'

    assert_text 'Front page section was successfully created'
  end

  test 'updating a front page section' do
    visit front_page_sections_url
    click_on 'Edit', match: :first

    fill_in 'front_page_section_button_text', with: @front_page_section.button_text
    select_from_chosen @front_page_section.image.name, from: 'Bilde'
    select_from_chosen @front_page_section.information_page.title, from: 'Informasjonsside'
    fill_in 'Undertittel', with: @front_page_section.subtitle
    fill_in 'Tittel', with: @front_page_section.title
    click_on 'Oppdater Front page section'

    assert_text 'Front page section was successfully updated'
    click_on 'Back'
  end

  test 'destroying a Front page section' do
    visit front_page_sections_url
    page.accept_confirm do
      click_on 'Destroy', match: :first
    end

    assert_text 'Front page section was successfully destroyed'
  end
end
