# frozen_string_literal: true

require 'feature_test'

class GraduationsFeatureTest < FeatureTest
  setup { screenshot_section :graduations }

  def test_show
    screenshot_group :show
    visit_with_login graduations_path
    screenshot :index
    find('table > tbody > tr:nth-child(1) > td:nth-child(4) > a').click
    screenshot :graduates
    find('a.nav-link', text: 'Eksaminatorer / Sensorer').click
    screenshot :censors
    find('a.nav-link', text: 'Skjema').click
    screenshot :forms
    find('a.nav-link', text: 'Handleliste belter').click
    screenshot :shopping_list
    find('a.nav-link', text: 'Dato / Gruppe').click
    screenshot :form
  end
end
