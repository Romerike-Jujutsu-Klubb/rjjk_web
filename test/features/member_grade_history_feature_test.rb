# frozen_string_literal: true
require 'capybara_setup'

class MemberGradeHistoryFeatureTest < ActionDispatch::IntegrationTest
  def test_grade_history
    login_and_visit '/members/grade_history_graph/800.png'
    screenshot('members/grade_history_graph')
  end
end
