require 'test_helper'

class ExaminersControllerTest < ActionController::TestCase
  setup do
    @examiner = examiners(:uwe_panda)
    login :admin
  end

  test 'should get index' do
    get :index
    assert_response :success
    assert_not_nil assigns(:examiners)
  end

  test 'should get new' do
    get :new
    assert_response :success
  end

  test 'should create examiner' do
    assert_difference('Examiner.count') do
      post :create, examiner: { approved_grades_at: @examiner.approved_grades_at, confirmed_at: @examiner.confirmed_at, graduation_id: @examiner.graduation_id, member_id: @examiner.member_id }
    end

    assert_redirected_to examiner_path(assigns(:examiner))
  end

  test 'should show examiner' do
    get :show, id: @examiner
    assert_response :success
  end

  test 'should get edit' do
    get :edit, id: @examiner
    assert_response :success
  end

  test 'should update examiner' do
    put :update, id: @examiner, examiner: { approved_grades_at: @examiner.approved_grades_at, confirmed_at: @examiner.confirmed_at, graduation_id: @examiner.graduation_id, member_id: @examiner.member_id }
    assert_redirected_to examiner_path(assigns(:examiner))
  end

  test 'should destroy examiner' do
    assert_difference('Examiner.count', -1) do
      delete :destroy, id: @examiner
    end

    assert_redirected_to examiners_path
  end
end
