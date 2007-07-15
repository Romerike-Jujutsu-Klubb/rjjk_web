require File.dirname(__FILE__) + '/../test_helper'
require 'info_controller'

# Re-raise errors caught by the controller.
class InfoController; def rescue_action(e) raise e end; end

class InfoControllerTest < Test::Unit::TestCase
  fixtures :users, :information_pages

  def setup
    @controller = InfoController.new
    @request    = ActionController::TestRequest.new
    @response   = ActionController::TestResponse.new
  end

  def test_index
    get :index
    assert_response :redirect
    assert_redirected_to :action => :show, :id => InformationPage.find(1)
  end

  def test_list
    get :list

    assert_response :success
    assert_template 'list'

    assert_not_nil assigns(:information_pages)
  end

  def test_show
    get :show, :id => 1

    assert_response :success
    assert_template 'show'

    assert_not_nil assigns(:information_page)
    assert assigns(:information_page).valid?
  end

  def test_new
    @request.session['user'] = users(:admin)
    get :new

    assert_response :success
    assert_template 'new'

    assert_not_nil assigns(:information_page)
  end

  def test_create
    num_information_pages = InformationPage.count

    @request.session['user'] = users(:admin)
    post :create, :information_page => {:title => 'an article'}

    assert_response :redirect
    assert_redirected_to :action => :show, :id => InformationPage.find_by_title('an article')

    assert_equal num_information_pages + 1, InformationPage.count
  end

  def test_edit
    @request.session['user'] = users(:admin)
    get :rediger, :id => 1

    assert_response :success
    assert_template 'rediger'

    assert_not_nil assigns(:information_page)
    assert assigns(:information_page).valid?
  end

  def test_update
    @request.session['user'] = users(:admin)
    post :update, :id => 1
    assert_response :redirect
    assert_redirected_to :action => 'show', :id => 1
  end

  def test_destroy
    assert_not_nil InformationPage.find(1)

    @request.session['user'] = users(:admin)
    post :destroy, :id => 1
    assert_response :redirect
    assert_redirected_to :action => 'list'

    assert_raise(ActiveRecord::RecordNotFound) {
      InformationPage.find(1)
    }
  end
end
