require File.dirname(__FILE__) + '/../test_helper'
require 'images_controller'

# Re-raise errors caught by the controller.
class ImagesController; def rescue_action(e) raise e end; end

class ImagesControllerTest < ActionController::TestCase
  fixtures :images

  def setup
    @controller = ImagesController.new
    @request    = ActionController::TestRequest.new
    @response   = ActionController::TestResponse.new

    @first_id = images(:one).id
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

    assert_not_nil assigns(:images)
  end

  def test_show
    get :show, :id => @first_id, :format => 'png'
    assert_response :success
  end

  def test_new
    get :new

    assert_response :success
    assert_template 'new'

    assert_not_nil assigns(:image)
  end

  def test_create
    login :tesla

    num_images = Image.count

    post :create, :image => {:name => 'new file', :content_type => 'image/png', :content_data => 'qwerty'}

    assert_response :redirect
    assert_redirected_to :action => :index

    assert_equal num_images + 1, Image.count
  end

  def test_edit
    get :edit, :id => @first_id

    assert_response :success
    assert_template 'edit'

    assert_not_nil assigns(:image)
    assert assigns(:image).valid?
  end

  def test_update
    post :update, :id => @first_id
    assert_response :redirect
    assert_redirected_to :action => :edit, :id => @first_id
  end

  def test_destroy
    assert_nothing_raised {
      Image.find(@first_id)
    }

    post :destroy, :id => @first_id
    assert_response :redirect
    assert_redirected_to :action => 'list'

    assert_raise(ActiveRecord::RecordNotFound) {
      Image.find(@first_id)
    }
  end

  def test_gallery
    get :gallery, :id => @first_id

    assert_response :success
    assert_template 'gallery'

    #assert_not_nil assigns(:image)
    assert_not_nil assigns(:images)
  end

end
