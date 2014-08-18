require File.dirname(__FILE__) + '/../test_helper'
require 'graduates_controller'

# Re-raise errors caught by the controller.
class GraduatesController
  def rescue_action(e)
    raise e
  end
end

class GraduatesControllerTest < ActionController::TestCase
  fixtures :users, :members, :graduations, :ranks, :graduates

  def setup
    @controller = GraduatesController.new
    @request = ActionController::TestRequest.new
    @response = ActionController::TestResponse.new

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
    get :show, :id => @first_id

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

    post :create, :graduate => {:member_id => members(:lars).id,
                                :graduation_id => graduations(:tiger).id,
                                :passed => true, :rank_id => ranks(:kyu_4).id,
                                :paid_graduation => true, :paid_belt => true}
    assert_no_errors :graduate
    assert_response :redirect
    assert_redirected_to :action => :index

    assert_equal num_graduates + 1, Graduate.count
  end

  def test_edit
    get :edit, :id => @first_id

    assert_response :success
    assert_template 'edit'
    assert_no_errors :graduate
  end

  def test_update
    post :update, id: @first_id, graduate: {}
    assert_no_errors :graduate
    assert_response :redirect
    assert_redirected_to action: :show, id: @first_id
  end

  def test_destroy
    assert_nothing_raised {
      Graduate.find(@first_id)
    }

    post :destroy, id: @first_id
    assert_response :redirect
    assert_redirected_to action: :index

    assert_raise(ActiveRecord::RecordNotFound) {
      Graduate.find(@first_id)
    }
  end
end
