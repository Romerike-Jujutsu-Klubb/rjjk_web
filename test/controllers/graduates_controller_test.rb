# frozen_string_literal: true

require 'test_helper'

class GraduatesControllerTest < ActionController::TestCase
  fixtures :users, :members, :graduations, :ranks, :graduates

  def setup
    @first_id = graduates(:one).id
    login(:admin)
  end

  def test_index
    get :index
    assert_response :success
    assert_template 'index'
    assert_not_nil assigns(:graduates)
  end

  def test_show
    get :show, params: { id: @first_id }

    assert_response :success
    assert_template 'show'
    assert_no_errors :graduate
  end

  def test_new
    get :new

    assert_response :success
    assert_template 'new'

    assert_not_nil assigns(:graduate)
  end

  def test_create
    num_graduates = Graduate.count

    post :create, params: { graduate: { member_id: members(:lars).id,
                                graduation_id: graduations(:tiger).id,
                                passed: true, rank_id: ranks(:kyu_4).id,
                                paid_graduation: true, paid_belt: true } }
    assert_no_errors :graduate
    assert_response :redirect
    assert_redirected_to action: :index

    assert_equal num_graduates + 1, Graduate.count
  end

  def test_edit
    get :edit, params: { id: @first_id }

    assert_response :success
    assert_template 'edit'
    assert_no_errors :graduate
  end

  def test_update
    post :update, params: { id: @first_id, graduate: { member_id: members(:lars).id } }
    assert_no_errors :graduate
    assert_response :redirect
    assert_redirected_to action: :show, id: @first_id
  end

  def test_destroy
    assert_nothing_raised do
      Graduate.find(@first_id)
    end

    post :destroy, params: { id: @first_id }
    assert_response :redirect
    assert_redirected_to action: :index

    assert_raise(ActiveRecord::RecordNotFound) do
      Graduate.find(@first_id)
    end
  end
end
