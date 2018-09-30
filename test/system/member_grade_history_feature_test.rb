# frozen_string_literal: true

require 'feature_test'

class MemberGradeHistoryFeatureTest < FeatureTest
  def test_grade_history
    login_and_visit member_reports_grade_history_graph_path(id: 800, format: :png)
    screenshot('member_reports/grade_history_graph', color_distance_limit: 79.1)
  end
end
