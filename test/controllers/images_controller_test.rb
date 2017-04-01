# frozen_string_literal: true

require 'test_helper'

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
  end

  def test_list
    get :index

    assert_response :success
    assert_template 'index'

    assert_not_nil assigns(:images)
  end

  def test_show
    get :show, params:{id: @first_id, format: 'png'}
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

    num_images = Image.count(:all)

    post :create, params: {image: { name: 'new file', content_type: 'image/png', content_data: 'qwerty' }}

    assert_response :redirect
    assert_redirected_to action: :gallery, id: assigns(:image).id

    assert_equal num_images + 1, Image.count(:all)
  end

  def test_edit
    get :edit, params:{id: @first_id}

    assert_response :success
    assert_template 'edit'

    assert_not_nil assigns(:image)
    assert assigns(:image).valid?
  end

  def test_update
    post :update, params:{id: @first_id, image: { approved: true }}
    assert_response :redirect
    assert_redirected_to action: :edit, id: @first_id
  end

  def test_destroy
    assert_nothing_raised do
      Image.find(@first_id)
    end

    post :destroy, params:{id: @first_id}
    assert_response :redirect
    assert_redirected_to action: :index

    assert_raise(ActiveRecord::RecordNotFound) do
      Image.find(@first_id)
    end
  end

  def test_gallery
    get :gallery, params:{id: @first_id}

    assert_response :success
    assert_template 'gallery'

    # assert_not_nil assigns(:image)
    assert_not_nil assigns(:images)
  end
end
