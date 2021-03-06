# frozen_string_literal: true

require 'integration_test'

class MemberReportsControllerTest < IntegrationTest
  test 'should get index' do
    get member_reports_url
    assert_response :success
  end

  def test_grade_history_graph
    get member_reports_grade_history_graph_url
    assert_response :success
  end

  def test_grade_history_graph_percentage
    get member_reports_grade_history_graph_url,
        params: { interval: 365, percentage: 67, step: 30 }
    assert_response :success
  end
end
