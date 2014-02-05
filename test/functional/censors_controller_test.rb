require File.dirname(__FILE__) + '/../test_helper'
require 'censors_controller'

# Re-raise errors caught by the controller.
class CensorsController; def rescue_action(e) raise e end; end

class CensorsControllerTest < ActionController::TestCase
  fixtures :users, :censors

  def setup
    @controller = CensorsController.new
    @request    = ActionController::TestRequest.new
    @response   = ActionController::TestResponse.new

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
    get :show, :id => @first_id
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

    post :create, :censor => {:graduation_id => graduations(:tiger).id, :member_id => members(:uwe).id}
    assert_no_errors :censor
    assert_response :redirect
    assert_redirected_to :action => :index

    assert_equal num_censors + 1, Censor.count
  end

  def test_edit
    get :edit, :id => @first_id
    assert_no_errors :censor
    assert_response :success
    assert_template 'edit'
  end

  def test_update
    post :update, :id => @first_id
    assert_no_errors :censor
    assert_response :redirect
    assert_redirected_to :action => 'show', :id => @first_id
  end

  def test_destroy
    assert_nothing_raised {
      Censor.find(@first_id)
    }

    post :destroy, :id => @first_id
    assert_response :redirect
    assert_redirected_to :action => 'index'

    assert_raise(ActiveRecord::RecordNotFound) {
      Censor.find(@first_id)
    }
  end
end
