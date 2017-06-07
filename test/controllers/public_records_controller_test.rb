# frozen_string_literal: true

require 'test_helper'

class PublicRecordsControllerTest < ActionController::TestCase
  setup do
    @public_record = public_records(:one)
    login(:admin)
  end

  test 'should get index' do
    get :index
    assert_response :success
    assert_not_nil assigns(:public_records)
  end

  test 'should get new' do
    get :new
    assert_response :success
  end

  test 'should create public_record' do
    assert_difference('PublicRecord.count') do
      post :create, params:{ public_record: {
          board_members: @public_record.board_members,
          chairman: @public_record.chairman, contact: @public_record.contact,
          deputies: @public_record.deputies
      } }
    end

    assert_redirected_to public_record_path(assigns(:public_record))
  end

  test 'should show public_record' do
    get :show, params:{ id: @public_record }
    assert_response :success
  end

  test 'should get edit' do
    get :edit, params:{ id: @public_record }
    assert_response :success
  end

  test 'should update public_record' do
    put :update, params:{ id: @public_record, public_record: {
        board_members: @public_record.board_members,
        chairman: @public_record.chairman, contact: @public_record.contact,
        deputies: @public_record.deputies
    } }
    assert_redirected_to public_record_path(assigns(:public_record))
  end

  test 'should destroy public_record' do
    assert_difference('PublicRecord.count', -1) do
      delete :destroy, params:{ id: @public_record }
    end

    assert_redirected_to public_records_path
  end
end
