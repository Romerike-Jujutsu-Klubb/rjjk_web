require File.dirname(__FILE__) + '/../test_helper'
require 'graduations_controller'

# Re-raise errors caught by the controller.
class GraduationsController; def rescue_action(e) raise e end; end

class GraduationsControllerTest < ActionController::TestCase
  fixtures :users, :martial_arts, :graduations

  def setup
    @controller = GraduationsController.new
    @request    = ActionController::TestRequest.new
    @response   = ActionController::TestResponse.new

    @first_id = graduations(:one).id
    login(:admin)
  end

  def test_index
    get :index
    assert_response :success
    assert_template 'list'
  end

  def test_list
    get :list

    assert_response :success
    assert_template 'list'

    assert_not_nil assigns(:graduations)
  end

  def test_show
    get :show, :id => @first_id

    assert_response :success
    assert_template 'show'

    assert_not_nil assigns(:graduation)
    assert assigns(:graduation).valid?
  end

  def test_new
    get :new

    assert_response :success
    assert_template 'new'

    assert_not_nil assigns(:graduation)
  end

  def test_create
    num_graduations = Graduation.count

    post :create, :graduation => {:held_on => '2007-10-07', :martial_art_id => 1}

    assert_response :redirect
    assert_redirected_to :action => 'list'

    assert_equal num_graduations + 1, Graduation.count
  end

  def test_edit
    get :edit, :id => @first_id

    assert_response :success
    assert_template 'edit'

    assert_not_nil assigns(:graduation)
    assert assigns(:graduation).valid?
  end

  def test_update
    post :update, :id => @first_id
    assert_response :redirect
    assert_redirected_to :action => 'show', :id => @first_id
  end

  def test_destroy
    assert_nothing_raised {
      Graduation.find(@first_id)
    }

    post :destroy, :id => @first_id
    assert_response :redirect
    assert_redirected_to :action => 'list'

    assert_raise(ActiveRecord::RecordNotFound) {
      Graduation.find(@first_id)
    }
  end
end
