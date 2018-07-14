# frozen_string_literal: true

require 'feature_test'

class InstructionFeatureTest < FeatureTest
  setup { screenshot_section :instruction }

  def test_index
    screenshot_group :index
    login_and_visit '/'
    click_menu 'Gruppeinstruktører'
    assert_current_path '/group_instructors'
    screenshot :index
  end

  def test_add_new
    screenshot_group :add_new
    visit_with_login '/group_instructors'
    find('a', text: 'Registrer gruppeinstruktør').click
    assert_current_path '/group_instructors/new'
    screenshot :new
    select 'Panda Torsdag', from: 'group_instructor_group_schedule_id'
    screenshot :new_with_group_schedule_selected
    select 'Uwe Kubosch', from: 'group_instructor_member_id'
    screenshot :new_with_member_selected
    select '2014: Januar→Juni', from: 'group_instructor_semester_id'
    screenshot :new_with_semester_selected
    screenshot :new_filled_in
    click_button 'Lagre'
    assert_current_path '/group_instructors'
    assert has_content? 'GroupInstructor was successfully created.'
  end
end
