# frozen_string_literal: true

require 'test_helper'

class MemberDrilldownControllerTest < ActionDispatch::IntegrationTest
  test 'should get index' do
    get member_drilldown_url
    assert_response :success
  end

  def test_should_get_index_with_list
    get member_drilldown_url search: { list: 1 }
    assert_response :success
  end
end
