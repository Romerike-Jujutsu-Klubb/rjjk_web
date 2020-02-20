# frozen_string_literal: true

require 'application_system_test_case'

class CardKeysTest < ApplicationSystemTestCase
  setup do
    @card_key = card_keys(:uwe)
    login
  end

  test 'visiting the index' do
    visit card_keys_url
    assert_selector 'h1', text: 'Nøkkelkort'
  end

  test 'creating a card key' do
    visit card_keys_url
    click_on 'Nytt kort'

    fill_in 'card_key_comment', with: @card_key.comment
    fill_in 'card_key_label', with: 'Card III'
    select_from_chosen @card_key.user.name, from: 'card_key[user_id]'
    click_on 'Lagre'

    assert_text 'Card key was successfully created'
  end

  test 'updating a card key' do
    visit card_keys_url
    find('td', text: 'First card').click
    fill_in 'card_key_comment', with: @card_key.comment
    fill_in 'card_key_label', with: 'New label'
    select_from_chosen @card_key.user.name, from: 'card_key[user_id]'
    click_on 'Lagre'

    assert_text 'Nøkkelkortet ble oppdatert.'
  end

  test 'destroying a card key' do
    visit card_keys_url
    find('td', text: 'First card').click
    page.accept_confirm { click_on 'Slett' }

    assert_text 'Nøkkelkortet ble slettet.'
  end
end
