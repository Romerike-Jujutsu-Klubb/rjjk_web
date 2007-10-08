require File.dirname(__FILE__) + '/../test_helper'
require 'martial_arts_controller'

# Re-raise errors caught by the controller.
class MartialArtsController; def rescue_action(e) raise e end; end

class MartialArtsControllerTest < Test::Unit::TestCase
  fixtures :martial_arts

  def setup
    @controller = MartialArtsController.new
    @request    = ActionController::TestRequest.new
    @response   = ActionController::TestResponse.new

    @first_id = martial_arts(:first).id
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

    assert_not_nil assigns(:martial_arts)
  end

  def test_show
    get :show, :id => @first_id

    assert_response :success
    assert_template 'show'

    assert_not_nil assigns(:martial_art)
    assert assigns(:martial_art).valid?
  end

  def test_new
    get :new

    assert_response :success
    assert_template 'new'

    assert_not_nil assigns(:martial_art)
  end

  def test_create
    num_martial_arts = MartialArt.count

    post :create, :martial_art => {}

    assert_response :redirect
    assert_redirected_to :action => 'list'

    assert_equal num_martial_arts + 1, MartialArt.count
  end

  def test_edit
    get :edit, :id => @first_id

    assert_response :success
    assert_template 'edit'

    assert_not_nil assigns(:martial_art)
    assert assigns(:martial_art).valid?
  end

  def test_update
    post :update, :id => @first_id
    assert_response :redirect
    assert_redirected_to :action => 'show', :id => @first_id
  end

  def test_destroy
    assert_nothing_raised {
      MartialArt.find(@first_id)
    }

    post :destroy, :id => @first_id
    assert_response :redirect
    assert_redirected_to :action => 'list'

    assert_raise(ActiveRecord::RecordNotFound) {
      MartialArt.find(@first_id)
    }
  end
end
