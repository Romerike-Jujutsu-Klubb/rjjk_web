# frozen_string_literal: true
require 'capybara_setup'

class MemberGradeHistoryFeatureTest < ActionDispatch::IntegrationTest
  def test_grade_history
    login_and_visit '/members/800/grade_history_graph.png'
    screenshot('members/grade_history_graph')
  end
end
