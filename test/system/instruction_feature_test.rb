# frozen_string_literal: true

require 'feature_test'

class InstructionFeatureTest < FeatureTest
  def test_index
    login_and_visit '/'
    click_menu 'Instruksjon'
    assert_current_path '/group_instructors'
    screenshot('instruction/index')
  end

  def test_add_new
    visit_with_login '/group_instructors'
    find('a', text: 'Registrer gruppeinstruktør').click
    assert_current_path '/group_instructors/new'
    screenshot('instruction/new')
    select 'Panda Torsdag', from: 'group_instructor_group_schedule_id'
    screenshot('instruction/new_with_group_schedule_selected')
    select 'Uwe Kubosch', from: 'group_instructor_member_id'
    screenshot('instruction/new_with_member_selected')
    select '2014: 01-01→06-30', from: 'group_instructor_semester_id'
    screenshot('instruction/new_with_semester_selected')
    screenshot('instruction/new_filled_in')
    click_button 'Lagre'
    assert_current_path '/group_instructors'
    assert has_content? 'GroupInstructor was successfully created.'
  end
end
