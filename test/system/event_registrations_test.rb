# frozen_string_literal: true

require 'application_system_test_case'

class EventRegistrationsTest < ApplicationSystemTestCase
  setup { screenshot_section :event_registrations }

  test 'visiting the index' do
    visit event_registration_index_url
    assert_selector 'h1', text: 'Påmelding til arrangement'
  end

  test 'registering for THE EVENT' do
    screenshot_group :register_the_event
    visit event_registration_index_url
    assert_selector 'h1', text: 'Påmelding til arrangement'
    screenshot :index

    click_on 'Påmelding'
    assert_selector 'h1', text: 'Påmelding til THE EVENT'
    screenshot :form

    fill_in 'event_invitee[user_attributes][name]', with: 'Hans Eriksen'
    fill_in 'event_invitee[user_attributes][email]', with: 'Hans.Eriksen@example.com'
    fill_in 'event_invitee[user_attributes][phone]', with: '+47 555 1234'
    fill_in 'event_invitee_organization', with: 'Jotunheimen KK'
    screenshot :filled_form

    click_on 'Registrer'
    assert_selector 'h1', text: 'Påmelding til THE EVENT'
    screenshot :options
  end

  test 'registering for THE EVENT with bad email' do
    screenshot_group :bad_email
    visit new_event_registration_url params: { event_invitee: { event_id: id(:one) } }
    assert_selector 'h1', text: 'Påmelding til THE EVENT'
    screenshot :form

    fill_in 'event_invitee[user_attributes][name]', with: 'Hans Eriksen'
    fill_in 'event_invitee[user_attributes][email]', with: 'Invalid Email'
    fill_in 'event_invitee[user_attributes][phone]', with: '+47 555 1234'
    fill_in 'event_invitee_organization', with: 'Jotunheimen KK'
    screenshot :filled_form

    click_on 'Registrer'
    assert_selector 'h1', text: 'Påmelding til THE EVENT'
    assert_selector '#event_invitee_user_attributes_email + .invalid-feedback', text: 'er ugyldig'
    screenshot :error_message
  end
end
