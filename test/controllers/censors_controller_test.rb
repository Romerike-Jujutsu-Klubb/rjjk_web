# frozen_string_literal: true

require 'controller_test'

class CensorsControllerTest < ActionController::TestCase
  fixtures :users, :censors

  def setup
    @first_id = censors(:lars_panda).id
    login :admin
  end

  def test_index
    get :index
    assert_response :success
  end

  def test_show
    get :show, params: { id: @first_id }
    assert_response :success
  end

  def test_new
    get :new
    assert_response :success
  end

  def test_create
    num_censors = Censor.count

    post :create, params: { censor: { graduation_id: graduations(:tiger).id, member_id: members(:uwe).id } }
    assert_response :redirect
    assert_redirected_to action: :index

    assert_equal num_censors + 1, Censor.count
  end

  def test_create_without_member_id
    post :create, params: { censor: { graduation_id: graduations(:tiger).id } }
  end

  def test_edit
    get :edit, params: { id: @first_id }
    assert_response :success
  end

  def test_update
    post :update, params: { id: @first_id, censor: { member_id: members(:lars).id } }
    assert_response :redirect
    assert_redirected_to action: 'show', id: @first_id
  end

  def test_confirm
    post :confirm, params: { id: @first_id }
    assert_response :redirect
  end

  def test_decline
    post :decline, params: { id: @first_id }
    assert_response :redirect
  end

  def test_destroy
    assert_nothing_raised do
      Censor.find(@first_id)
    end

    post :destroy, params: { id: @first_id }
    assert_response :redirect
    assert_redirected_to action: 'index'

    assert_raise(ActiveRecord::RecordNotFound) do
      Censor.find(@first_id)
    end
  end
end
