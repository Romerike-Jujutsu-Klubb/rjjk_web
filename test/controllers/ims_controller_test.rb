# frozen_string_literal: true

require 'test_helper'

class ImsControllerTest < ActionDispatch::IntegrationTest
  test 'should get index' do
    get ims_index_url
    assert_response :success
  end

  test 'should get import' do
    post ims_import_url
    assert_redirected_to ims_index_path
  end
end
