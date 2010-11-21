require File.dirname(__FILE__) + '/../test_helper'
require 'ranks_controller'

# Re-raise errors caught by the controller.
class RanksController; def rescue_action(e) raise e end; end

class RanksControllerTest < ActionController::TestCase
  fixtures :ranks

  def setup
    @controller = RanksController.new
    @request    = ActionController::TestRequest.new
    @response   = ActionController::TestResponse.new

    @first_id = ranks(:one).id
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

    assert_not_nil assigns(:ranks)
  end

  def test_show
    get :show, :id => @first_id

    assert_response :success
    assert_template 'show'

    assert_not_nil assigns(:rank)
    assert assigns(:rank).valid?
  end

  def test_new
    get :new

    assert_response :success
    assert_template 'new'

    assert_not_nil assigns(:rank)
  end

  def test_create
    num_ranks = Rank.count

    post :create, :rank => {:name => '5.kyu', :colour => 'gult', :position => 1, :martial_art_id => 1}

    assert_response :redirect
    assert_redirected_to :action => 'list'

    assert_equal num_ranks + 1, Rank.count
  end

  def test_edit
    get :edit, :id => @first_id

    assert_response :success
    assert_template 'edit'

    assert_not_nil assigns(:rank)
    assert assigns(:rank).valid?
  end

  def test_update
    post :update, :id => @first_id
    assert_response :redirect
    assert_redirected_to :action => 'show', :id => @first_id
  end

  def test_destroy
    assert_nothing_raised {
      Rank.find(@first_id)
    }

    post :destroy, :id => @first_id
    assert_response :redirect
    assert_redirected_to :action => 'list'

    assert_raise(ActiveRecord::RecordNotFound) {
      Rank.find(@first_id)
    }
  end
end
