# frozen_string_literal: true

require 'integration_test'

class CensorsControllerTest < IntegrationTest
  def setup
    @first_id = censors(:lars_panda).id
    login :uwe
  end

  def test_index
    get censors_path
    assert_response :success
  end

  def test_show
    get censor_path(@first_id)
    assert_response :success
  end

  def test_new
    get new_censor_path
    assert_response :success
  end

  def test_create
    num_censors = Censor.count

    post censors_path, params: { censor: { graduation_id: graduations(:tiger).id, member_id: members(:uwe).id } }
    assert_response :redirect
    assert_redirected_to action: :index

    assert_equal num_censors + 1, Censor.count
  end

  def test_create_without_member_id
    post censors_path, params: { censor: { graduation_id: graduations(:tiger).id } }
  end

  def test_edit
    get edit_censor_path(@first_id)
    assert_response :success
  end

  def test_update
    patch censor_path(@first_id), params: { censor: { member_id: members(:lars).id } }
    assert_response :redirect
    assert_redirected_to action: 'show', id: @first_id
  end

  def test_accept
    post accept_censor_path(@first_id)
    assert_response :redirect
  end

  def test_accept_get
    get accept_censor_path(@first_id)
    assert_response :redirect
  end

  def test_decline
    post decline_censor_path(@first_id)
    assert_response :redirect
  end

  def test_decline_get
    get decline_censor_path(@first_id)
    assert_response :redirect
  end

  def test_destroy
    assert_nothing_raised do
      Censor.find(@first_id)
    end

    delete censor_path(@first_id)
    assert_response :redirect
    assert_redirected_to action: 'index'

    assert_raise(ActiveRecord::RecordNotFound) do
      Censor.find(@first_id)
    end
  end
end
