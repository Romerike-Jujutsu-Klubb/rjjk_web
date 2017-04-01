# frozen_string_literal: true

require 'test_helper'

class ElectionsControllerTest < ActionController::TestCase
  setup do
    @election = elections(:chairman)
    login(:admin)
  end

  test 'should get index' do
    get :index
    assert_response :success
  end

  test 'should get new' do
    get :new
    assert_response :success
  end

  test 'should create election' do
    assert_difference('Election.count') do
      post :create, params:{election: { annual_meeting_id: @election.annual_meeting_id,
          member_id: @election.member_id, resigned_on: @election.resigned_on,
          role_id: @election.role_id, years: 2 }}
    end

    assert_redirected_to elections_path
  end

  test 'should show election' do
    get :show, params:{id: @election}
    assert_response :success
  end

  test 'should get edit' do
    get :edit, params:{id: @election}
    assert_response :success
  end

  test 'should update election' do
    put :update, params:{id: @election, election: {
        annual_meeting_id: @election.annual_meeting_id,
        member_id: @election.member_id,
        resigned_on: @election.resigned_on,
        role_id: @election.role_id,
    }}
    assert_redirected_to elections_path
  end

  test 'should destroy election' do
    assert_difference('Election.count', -1) do
      delete :destroy, params:{id: @election}
    end

    assert_redirected_to elections_path
  end
end
