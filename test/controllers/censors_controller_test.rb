# frozen_string_literal: true
require 'test_helper'

class CensorsControllerTest < ActionController::TestCase
  fixtures :users, :censors

  def setup
    @first_id = censors(:one).id
    login :admin
  end

  def test_index
    get :index
    assert_response :success
    assert_template 'index'
    assert_not_nil assigns(:censors)
  end

  def test_show
    get :show, params:{id: @first_id}
    assert_no_errors :censor
    assert_response :success
    assert_template 'show'
  end

  def test_new
    get :new

    assert_response :success
    assert_template 'new'

    assert_not_nil assigns(:censor)
  end

  def test_create
    num_censors = Censor.count

    post :create, params:{censor: { graduation_id: graduations(:tiger).id, member_id: members(:uwe).id }}
    assert_no_errors :censor
    assert_response :redirect
    assert_redirected_to action: :index

    assert_equal num_censors + 1, Censor.count
  end

  def test_edit
    get :edit, params:{id: @first_id}
    assert_no_errors :censor
    assert_response :success
    assert_template 'edit'
  end

  def test_update
    post :update, params:{id: @first_id, censor: {member_id: members(:lars).id}}
    assert_no_errors :censor
    assert_response :redirect
    assert_redirected_to action: 'show', id: @first_id
  end

  def test_destroy
    assert_nothing_raised do
      Censor.find(@first_id)
    end

    post :destroy, params:{id: @first_id}
    assert_response :redirect
    assert_redirected_to action: 'index'

    assert_raise(ActiveRecord::RecordNotFound) do
      Censor.find(@first_id)
    end
  end
end
