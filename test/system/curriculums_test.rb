# frozen_string_literal: true

require 'application_system_test_case'

class CurriculumsTest < ApplicationSystemTestCase
  setup do
    @curriculum = curriculum_groups(:voksne)
    login(:newbie)
  end

  test 'visiting the index' do
    visit curriculums_url
    assert_selector 'h2', text: 'Pensum Voksne'
  end
end
