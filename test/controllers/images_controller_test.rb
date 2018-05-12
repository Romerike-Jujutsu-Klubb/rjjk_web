# frozen_string_literal: true

require 'controller_test'

class ImagesControllerTest < ActionController::TestCase
  fixtures :images

  def setup
    @first_id = images(:one).id
    login(:admin)
  end

  def test_index
    get :index
    assert_response :success
    assert_template 'index'
    assert_not_nil assigns(:images)
  end

  def test_show
    get :show, params: { id: @first_id, format: 'png' }
    assert_response :success
  end

  def test_inline
    get :inline, params: { id: @first_id, format: 'png' }
    assert_response :success
  end

  def test_new
    get :new

    assert_response :success
    assert_template 'new'

    assert_not_nil assigns(:image)
  end

  def test_create
    login :lars

    assert_difference('Image.count') do
      post :create, params: { image: { name: 'new file', content_type: 'image/png', content_data: 'qwerty' } }
    end

    assert_response :redirect
    assert_redirected_to action: :gallery, id: assigns(:image).id
    image = Image.last
    assert_equal 'new file', image.name
    assert_equal 'image/png', image.content_type
    assert_equal 6, image.content_data.length
  end

  def test_create_with_file
    images(:one).destroy! # same content
    login :lars

    assert_difference('Image.count') do
      post :create, params: { image: {
        name: 'new file', content_type: 'image/png', file: fixture_file_upload('files/tiny.png')
      } }
    end

    assert_response :redirect
    assert_redirected_to action: :gallery, id: assigns(:image).id
    image = Image.last
    assert_equal 'new file', image.name
    assert_equal 'image/png', image.content_type
    assert_equal 67, image.content_data.length
  end

  def test_create_with_file_gets_name
    images(:one).destroy! # same content
    login :lars

    assert_difference('Image.count') do
      post :create, params: { image: { file: fixture_file_upload('files/tiny.png', 'image/png') } }
    end

    assert_response :redirect
    assert_redirected_to action: :gallery, id: assigns(:image).id
    image = Image.last
    assert_equal 'tiny.png', image.name
    assert_equal 'image/png', image.content_type
    assert_equal 67, image.content_data.length
  end

  def test_create_same_content_fails
    login :lars

    assert_no_difference('Image.count') do
      post :create, params: { image: { file: fixture_file_upload('files/tiny.png') } }
    end

    assert_response :success
  end

  def test_edit
    get :edit, params: { id: @first_id }

    assert_response :success
    assert_template 'edit'

    assert_not_nil assigns(:image)
    assert assigns(:image).valid?
  end

  def test_update
    post :update, params: { id: @first_id, image: { approved: true } }
    assert_response :redirect
    assert_redirected_to action: :edit, id: @first_id
  end

  def test_destroy
    assert_nothing_raised do
      Image.find(@first_id)
    end

    post :destroy, params: { id: @first_id }
    assert_response :redirect
    assert_redirected_to action: :index

    assert_raise(ActiveRecord::RecordNotFound) do
      Image.find(@first_id)
    end
  end

  def test_gallery
    get :gallery, params: { id: @first_id }

    assert_response :success
    assert_template 'gallery'
    assert_not_nil assigns(:images)
  end

  def test_mine
    get :mine

    assert_response :success
    assert_template 'gallery'
    assert_not_nil assigns(:images)
  end
end
