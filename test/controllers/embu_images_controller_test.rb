require 'test_helper'

class EmbuImagesControllerTest < ActionController::TestCase
  setup do
    login :lars
    @embu_image = embu_images(:one)
  end

  test 'should get index' do
    get :index
    assert_response :success
    assert_not_nil assigns(:embu_images)
  end

  test 'should get new' do
    get :new
    assert_response :success
  end

  test 'should create embu_image' do
    assert_difference('EmbuImage.count') do
      post :create, embu_image: { embu_id: embus(:one).id, image_id: images(:one) }
    end

    assert_redirected_to embu_image_path(assigns(:embu_image))
  end

  test 'should show embu_image' do
    get :show, id: @embu_image
    assert_response :success
  end

  test 'should get edit' do
    get :edit, id: @embu_image
    assert_response :success
  end

  test 'should update embu_image' do
    put :update, id: @embu_image, embu_image: {  }
    assert_no_errors :embu_image
    assert_redirected_to embu_image_path(assigns(:embu_image))
  end

  test 'should destroy embu_image' do
    assert_difference('EmbuImage.count', -1) do
      delete :destroy, id: @embu_image
    end

    assert_redirected_to embu_images_path
  end
end
