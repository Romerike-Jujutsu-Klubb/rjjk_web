# frozen_string_literal: true

require 'application_system_test_case'

class PracticeGroupsTest < ApplicationSystemTestCase
  setup { login }

  test 'new' do
    visit groups_url
    assert_selector 'h1', text: 'Treningsgrupper'
    screenshot :index
    click_on 'Ny gruppe'
    screenshot :new
    fill_in 'Navn', with: 'Ungdomsgruppa'
    select 'Voksne', from: 'group_curriculum_group_id'
    fill_in 'group[from_age]', with: '13'
    fill_in 'group[to_age]', with: '19'
    screenshot :form_filled
    click_on 'Lagre'
    find('h3', text: 'Ungdomsgruppa').click
    screenshot :saved
  end
end
