# frozen_string_literal: true

require 'test_helper'

class ImsControllerTest < ActionDispatch::IntegrationTest
  test 'should get index' do
    get ims_index_url
    assert_response :success
  end

  test 'should post import xls' do
    post ims_import_url, params: { file: fixture_file_upload('MembershipStatistics-1610036403783.xls') }
    assert_redirected_to ims_index_path
  end

  test 'should post import csv' do
    post ims_import_url, params: { file: fixture_file_upload('MembershipStatistics-1610092032730.csv') }
    assert_redirected_to ims_index_path
  end

  test 'should post import empty xls' do
    post ims_import_url, params: { file: fixture_file_upload('Empty.xls') }
    assert_redirected_to ims_index_path
  end

  test 'should post import empty xlsx' do
    post ims_import_url, params: { file: fixture_file_upload('Empty.xlsx') }
    assert_redirected_to ims_index_path
  end

  test 'should post import empty csv' do
    post ims_import_url, params: { file: fixture_file_upload('Empty.csv') }
    assert_redirected_to ims_index_path
  end
end
