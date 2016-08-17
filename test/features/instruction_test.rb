# frozen_string_literal: true
require 'capybara_setup'

class InstructionTest < ActionDispatch::IntegrationTest
  def test_index
    login_and_visit '/'
    click_link 'Instruksjon'
    assert_current_path '/group_instructors'
    screenshot('instruction/index')
  end

  def test_add_new
    visit_with_login '/group_instructors'
    click_link 'Registrer gruppeinstruktør'
    assert_current_path '/group_instructors/new'
    screenshot('instruction/new')
    select 'Panda Torsdag', from: 'group_instructor_group_schedule_id'
    screenshot('instruction/new_with_group_schedule_selected')
    select 'Uwe Kubosch', from: 'group_instructor_member_id'
    screenshot('instruction/new_with_member_selected')
    select '2100: 01-01→12-31', from: 'group_instructor_semester_id'
    screenshot('instruction/new_with_semester_selected')
    screenshot('instruction/new_filled_in')
    click_button 'Lagre'
    assert_current_path '/group_instructors'
    assert has_content? 'GroupInstructor was successfully created.'
  end
end
