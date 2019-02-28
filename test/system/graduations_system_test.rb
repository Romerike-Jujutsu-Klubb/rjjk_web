# frozen_string_literal: true

require 'application_system_test_case'

class GraduationsSystemTest < ApplicationSystemTestCase
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

  def test_new
    screenshot_group :new
    visit_with_login graduations_path
    find("a[href='#{new_graduation_path}']").click
    screenshot :form
    click_link_or_button 'Lagre'
    screenshot :form_errors
  end

  def test_new_with_params
    screenshot_group :new_with_params
    visit_with_login new_graduation_path(graduation: {
      group_id: groups(:panda).id, group_notification: true, held_on: '2013-10-21'
    })
    screenshot :form
  end
end
