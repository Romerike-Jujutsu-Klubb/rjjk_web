require 'test_helper'

class EmbusControllerTest < ActionController::TestCase
  setup do
    @embu = embus(:one)
  end

  test "should get index" do
    get :index
    assert_response :success
    assert_not_nil assigns(:embus)
  end

  test "should get new" do
    get :new
    assert_response :success
  end

  test "should create embu" do
    assert_difference('Embu.count') do
      post :create, embu: @embu.attributes
    end

    assert_redirected_to embu_path(assigns(:embu))
  end

  test "should show embu" do
    get :show, id: @embu
    assert_response :success
  end

  test "should get edit" do
    get :edit, id: @embu
    assert_response :success
  end

  test "should update embu" do
    put :update, id: @embu, embu: @embu.attributes
    assert_redirected_to embu_path(assigns(:embu))
  end

  test "should destroy embu" do
    assert_difference('Embu.count', -1) do
      delete :destroy, id: @embu
    end

    assert_redirected_to embus_path
  end
end
