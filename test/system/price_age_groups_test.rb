# frozen_string_literal: true

require 'application_system_test_case'

class PriceAgeGroupsTest < ApplicationSystemTestCase
  setup do
    screenshot_section :price_age_groups
    @price_age_group = price_age_groups(:barn)
    login
  end

  test 'visiting the index' do
    visit price_age_groups_url
    assert_selector 'h1', text: 'Prisgrupper'
  end

  test 'creating a Price age group' do
    screenshot_group :create
    visit price_age_groups_url

    screenshot :index
    click_on 'Legg til prisgruppe'

    fill_in 'Nedre aldersgrense', with: 1
    fill_in 'Månedsavgift', with: @price_age_group.monthly_fee
    fill_in 'Navn', with: 'Mygger'
    fill_in 'Øvre aldersgrense', with: 4
    fill_in 'Årskontingent', with: @price_age_group.yearly_fee
    click_on 'Lagre'

    assert_text 'Price age group was successfully created'
    click_on 'Prisgruppeliste'
  end

  test 'updating a Price age group' do
    visit price_age_groups_url
    first('tbody tr').click

    fill_in 'Nedre aldersgrense', with: 1
    fill_in 'Månedsavgift', with: @price_age_group.monthly_fee
    fill_in 'Navn', with: 'Mygger'
    fill_in 'Øvre aldersgrense', with: 4
    fill_in 'Årskontingent', with: @price_age_group.yearly_fee
    click_on 'Lagre'

    assert_text 'Price age group was successfully updated'
    click_on 'Prisgruppeliste'
  end

  test 'destroying a Price age group' do
    visit price_age_groups_url
    page.accept_confirm do
      click_on 'Destroy', match: :first
    end

    assert_text 'Price age group was successfully destroyed'
  end
end
