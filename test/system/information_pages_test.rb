# frozen_string_literal: true

require 'application_system_test_case'

class InformationPagesTest < ApplicationSystemTestCase
  setup do
    screenshot_section :information_pages
    login :lars
  end

  test 'visiting the index' do
    screenshot_group :index
    visit information_pages_path
    assert_selector 'h1', text: 'Informasjonssider'
    screenshot :index
  end

  test 'create' do
    screenshot_group :create
    visit root_path
    # assert_selector "h1", text: "Web"
    click_menu 'Ny info-side', section: 'Web'
    assert_selector 'h1', text: 'Opprette ny informasjonsside'
    screenshot :new
    fill_in :information_page_title, with: 'Serenity'
    fill_in :information_page_body, with: 'The Firefly roams the galaxy seeking peace and friendship.'
    screenshot :filled_in
    click_on 'Lagre'
    assert_selector 'p', text: 'InformationPage was successfully created'
    screenshot :saved
  end
end
