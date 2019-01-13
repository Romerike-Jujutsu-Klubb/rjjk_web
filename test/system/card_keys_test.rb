require "application_system_test_case"

class CardKeysTest < ApplicationSystemTestCase
  setup do
    @card_key = card_keys(:one)
  end

  test "visiting the index" do
    visit card_keys_url
    assert_selector "h1", text: "Card Keys"
  end

  test "creating a Card key" do
    visit card_keys_url
    click_on "New Card Key"

    fill_in "Comment", with: @card_key.comment
    fill_in "Label", with: @card_key.label
    fill_in "User", with: @card_key.user_id
    click_on "Create Card key"

    assert_text "Card key was successfully created"
    click_on "Back"
  end

  test "updating a Card key" do
    visit card_keys_url
    click_on "Edit", match: :first

    fill_in "Comment", with: @card_key.comment
    fill_in "Label", with: @card_key.label
    fill_in "User", with: @card_key.user_id
    click_on "Update Card key"

    assert_text "Card key was successfully updated"
    click_on "Back"
  end

  test "destroying a Card key" do
    visit card_keys_url
    page.accept_confirm do
      click_on "Destroy", match: :first
    end

    assert_text "Card key was successfully destroyed"
  end
end
