# frozen_string_literal: true

require 'application_system_test_case'

class CurriculumsTest < ApplicationSystemTestCase
  setup do
    @curriculum = curriculum_groups(:voksne)
    login
  end

  test 'visiting the index' do
    visit curriculums_url
    assert_selector 'h1', text: 'Curriculums'
  end

  test 'creating a Curriculum' do
    visit curriculums_url
    click_on 'New Curriculum'

    fill_in 'Color', with: @curriculum.color
    fill_in 'curriculum[from_age]', with: @curriculum.from_age
    fill_in 'curriculum[martial_art_id]', with: @curriculum.martial_art_id
    fill_in 'curriculum[name]', with: @curriculum.name
    fill_in 'Position', with: @curriculum.position
    fill_in 'curriculum[to_age]', with: @curriculum.to_age
    click_on 'Lag Curriculum'

    assert_text 'Curriculum was successfully created'
  end

  test 'updating a Curriculum' do
    visit curriculums_url
    click_on 'Edit', match: :first

    fill_in 'Color', with: @curriculum.color
    fill_in 'curriculum[from_age]', with: @curriculum.from_age
    fill_in 'curriculum[martial_art_id]', with: @curriculum.martial_art_id
    fill_in 'curriculum[name]', with: @curriculum.name
    fill_in 'curriculum[position]', with: @curriculum.position
    fill_in 'curriculum[to_age]', with: @curriculum.to_age
    click_on 'Oppdater Curriculum'

    assert_text 'Curriculum was successfully updated'
  end

  test 'destroying a Curriculum' do
    visit curriculums_url
    page.accept_confirm do
      click_on 'Destroy', match: :first
    end

    assert_text 'Curriculum was successfully destroyed'
  end
end
