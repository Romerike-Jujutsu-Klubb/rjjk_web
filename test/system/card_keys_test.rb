# frozen_string_literal: true

require 'application_system_test_case'

class CardKeysTest < ApplicationSystemTestCase
  setup do
    @card_key = card_keys(:one)
  end

  test 'visiting the index' do
    visit card_keys_url
    assert_selector 'h1', text: 'Nøkkelkort'
  end

  test 'creating a Card key' do
    visit card_keys_url
    click_on 'Nytt kort'

    fill_in 'Kommentar', with: @card_key.comment
    fill_in 'Kortnummer', with: @card_key.label
    select_from_chosen @card_key.user.name, from: 'card_key[user_id]'
    click_on 'Lagre'

    assert_text 'Card key was successfully created'
  end

  test 'updating a Card key' do
    visit card_keys_url
    click_on 'Rediger', match: :first

    fill_in 'Kommentar', with: @card_key.comment
    fill_in 'Kortnummer', with: @card_key.label
    select_from_chosen @card_key.user.name, from: 'card_key[user_id]'
    click_on 'Lagre'

    assert_text 'Card key was successfully updated'
  end

  test 'destroying a Card key' do
    visit card_keys_url
    page.accept_confirm do
      click_on 'Slett', match: :first
    end

    assert_text 'Card key was successfully destroyed'
  end
end
