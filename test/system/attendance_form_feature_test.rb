# frozen_string_literal: true

require 'application_system_test_case'

class AttendanceFormFeatureTest < ApplicationSystemTestCase
  setup { screenshot_section :attendance }

  def test_index
    screenshot_group :form
    login_and_visit '/'
    click_menu('Oppmøte', section: 'Instruksjon')
    assert_current_path attendance_forms_path
    screenshot :index
  end
end
