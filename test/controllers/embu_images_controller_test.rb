# frozen_string_literal: true

require 'controller_test'

class EmbuImagesControllerTest < ActionController::TestCase
  setup do
    login :lars
    @embu_image = embu_images(:one)
  end

  test 'should get index' do
    get :index
    assert_response :success
  end

  test 'should get new' do
    get :new
    assert_response :success
  end

  test 'should create embu_image' do
    assert_difference('EmbuImage.count') do
      post :create, params: { embu_image: { embu_id: embus(:one).id, image_id: images(:one) } }
    end

    assert_redirected_to embu_image_path(EmbuImage.last)
  end

  test 'should show embu_image' do
    get :show, params: { id: @embu_image }
    assert_response :success
  end

  test 'should get edit' do
    get :edit, params: { id: @embu_image }
    assert_response :success
  end

  test 'should update embu_image' do
    put :update, params: { id: @embu_image, embu_image: { embu_id: id(:one), image_id: id(:one) } }
    assert_redirected_to embu_image_path(@embu_image)
  end

  test 'should destroy embu_image' do
    assert_difference('EmbuImage.count', -1) do
      delete :destroy, params: { id: @embu_image }
    end

    assert_redirected_to embu_images_path
  end
end
