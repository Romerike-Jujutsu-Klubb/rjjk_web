# encoding: utf-8
require 'test_helper'

class InstructionTest < ActionDispatch::IntegrationTest
  def test_index
    login_and_visit '/'
    click_link 'Instruksjon'
    sleep 1
    assert_equal '/group_instructors', current_path
    screenshot('instruction/index')
  end

  def test_add_new
    visit_with_login '/group_instructors'
    click_link 'Registrer gruppeinstruktør'
    assert_current_path '/group_instructors/new'
    screenshot('instruction/new')
    select 'Panda Torsdag', from: 'group_instructor_group_schedule_id'
    sleep 60
    select 'Uwe Kubosch', from: 'group_instructor_member_id'
    select '2013: 07-01→12-31', from: 'group_instructor_member_id'
    screenshot('instruction/new_filled_in')
    click_button 'Lagre'
    assert_equal '/group_instructors', current_path
    find
  end

end
