# frozen_string_literal: true

require 'application_system_test_case'

class PriceAgeGroupsTest < ApplicationSystemTestCase
  setup do
    @price_age_group = price_age_groups(:panda)
    login
  end

  test 'visiting the index' do
    visit price_age_groups_url
    assert_selector 'h1', text: 'Price Age Groups'
  end

  test 'creating a Price age group' do
    visit price_age_groups_url
    click_on 'New Price age group'

    fill_in 'From age', with: 1
    fill_in 'Monthly fee', with: @price_age_group.monthly_fee
    fill_in 'Name', with: 'Mygger'
    fill_in 'To age', with: 4
    fill_in 'Yearly fee', with: @price_age_group.yearly_fee
    click_on 'Lag Price age group'

    assert_text 'Price age group was successfully created'
    click_on 'Back'
  end

  test 'updating a Price age group' do
    visit price_age_groups_url
    click_on 'Edit', match: :first

    fill_in 'From age', with: 1
    fill_in 'Monthly fee', with: @price_age_group.monthly_fee
    fill_in 'Name', with: 'Mygger'
    fill_in 'To age', with: 4
    fill_in 'Yearly fee', with: @price_age_group.yearly_fee
    click_on 'Oppdater Price age group'

    assert_text 'Price age group was successfully updated'
    click_on 'Back'
  end

  test 'destroying a Price age group' do
    visit price_age_groups_url
    page.accept_confirm do
      click_on 'Destroy', match: :first
    end

    assert_text 'Price age group was successfully destroyed'
  end
end
