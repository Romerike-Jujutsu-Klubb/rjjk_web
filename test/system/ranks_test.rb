# frozen_string_literal: true

require 'application_system_test_case'

class RanksTest < ApplicationSystemTestCase
  setup do
    screenshot_section :ranks
    login
    @rank = ranks(:kyu_5)
  end

  test 'visiting the index' do
    screenshot_group :index
    visit ranks_path
    assert_selector 'h1', text: 'Grader'
    screenshot :initial
  end

  test 'creating a Rank' do
    visit ranks_path
    click_on 'Legg til grad'

    select 'Kei Wa Ryu', from: :rank_martial_art_id
    select 'Voksne', from: :rank_group_id
    fill_in 'rank_description', with: @rank.description
    fill_in 'rank_position', with: 10
    fill_in 'rank_standard_months', with: 6
    click_on 'Lagre'

    assert_text 'Rank was successfully created'
  end

  test 'updating a Rank' do
    visit ranks_path
    click_on 'Rediger', match: :first

    fill_in 'rank_description', with: @rank.description
    click_on 'Lagre'

    assert_text 'Rank was successfully updated'
  end

  # test 'destroying a Rank' do
  #   visit ranks_path
  #   click_on 'Rediger', match: :first
  #   page.accept_confirm do
  #     click_on 'Slett'
  #   end
  #
  #   assert_text 'Rank was successfully destroyed'
  # end
end
