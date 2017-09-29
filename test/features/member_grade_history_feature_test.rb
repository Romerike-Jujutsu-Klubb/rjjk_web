# frozen_string_literal: true

require 'feature_test'

class MemberGradeHistoryFeatureTest < FeatureTest
  def test_grade_history
    login_and_visit '/members/800/grade_history_graph.png'
    screenshot('members/grade_history_graph', color_distance_limit: 79.1)
  end
end
