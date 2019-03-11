# frozen_string_literal: true

require 'controller_test'

class GraduatesControllerTest < ActionController::TestCase
  def setup
    @graduate = graduates(:lars_kyu_1)
    @first_id = @graduate.id
    login(:admin)
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
    num_graduates = Graduate.count

    post :create, params: { graduate: { member_id: members(:lars).id,
                                        graduation_id: graduations(:tiger).id,
                                        passed: true, rank_id: ranks(:kyu_4).id,
                                        paid_graduation: true, paid_belt: true } }
    assert_response :redirect
    assert_redirected_to action: :index
    assert_equal num_graduates + 1, Graduate.count
  end

  def test_edit
    get :edit, params: { id: @first_id }
    assert_response :success
  end

  def test_update
    post :update, params: { id: @first_id, graduate: { member_id: members(:lars).id } }
    assert_response :redirect
    assert_redirected_to action: :show, id: @first_id
  end

  def test_destroy
    assert_nothing_raised do
      @graduate.reload
    end

    post :destroy, params: { id: @first_id }
    assert_response :redirect
    assert_redirected_to edit_graduation_path(@graduate.graduation_id)

    assert_raise(ActiveRecord::RecordNotFound) do
      @graduate.reload
    end
  end
end
