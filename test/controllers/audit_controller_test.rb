# frozen_string_literal: true

require 'test_helper'

class AuditControllerTest < ActionDispatch::IntegrationTest
  test 'should get index' do
    get audit_url('Member', id(:lars))
    assert_response :success
  end
end
