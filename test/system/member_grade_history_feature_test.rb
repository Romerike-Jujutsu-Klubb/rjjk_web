# frozen_string_literal: true

require 'application_system_test_case'

class MemberGradeHistoryFeatureTest < ApplicationSystemTestCase
  def test_grade_history
    visit_with_login member_reports_grade_history_graph_path
    screenshot('grade_history_graph', color_distance_limit: 79.1)
  end
end
