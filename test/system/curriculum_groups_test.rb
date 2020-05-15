# frozen_string_literal: true

require 'application_system_test_case'

class CurriculumGroupsTest < ApplicationSystemTestCase
  setup do
    @curriculum_group = curriculum_groups(:voksne)
    login
  end

  test 'visiting the index' do
    visit curriculum_groups_url
    assert_selector 'h1', text: 'Pensum'
  end

  test 'creating a Curriculum group' do
    visit curriculum_groups_url
    click_on 'Nytt pensum'

    fill_in 'Color', with: @curriculum_group.color
    fill_in 'curriculum_group[from_age]', with: @curriculum_group.from_age
    fill_in 'curriculum_group[martial_art_id]', with: @curriculum_group.martial_art_id
    fill_in 'curriculum_group[name]', with: @curriculum_group.name
    fill_in 'Position', with: @curriculum_group.position
    fill_in 'curriculum_group[to_age]', with: @curriculum_group.to_age
    click_on 'Lag Curriculum group'

    assert_text 'Curriculum group was successfully created'
  end

  test 'updating a Curriculum group' do
    visit curriculum_groups_url
    find('tbody tr td', match: :first).click
    click_on 'Endre'

    fill_in 'Color', with: @curriculum_group.color
    fill_in 'curriculum_group[from_age]', with: @curriculum_group.from_age
    fill_in 'curriculum_group[martial_art_id]', with: @curriculum_group.martial_art_id
    fill_in 'curriculum_group[name]', with: @curriculum_group.name
    fill_in 'curriculum_group[position]', with: @curriculum_group.position
    fill_in 'curriculum_group[to_age]', with: @curriculum_group.to_age
    click_on 'Oppdater Curriculum'
  end

  test 'destroying a Curriculum group' do
    visit curriculum_groups_url
    page.accept_confirm { find('.fa-trash-alt').click }
    assert_text 'Curriculum group was successfully destroyed'
  end
end
