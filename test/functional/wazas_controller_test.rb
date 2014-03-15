require 'test_helper'

class WazasControllerTest < ActionController::TestCase
  setup do
    @waza = wazas(:tsuki)
  end

  test 'should get index' do
    get :index
    assert_response :success
    assert_not_nil assigns(:wazas)
  end

  test 'should get new' do
    get :new
    assert_response :success
  end

  test 'should create waza' do
    assert_difference('Waza.count') do
      post :create, waza: { description: @waza.description, name: 'Super-punch',
          translation: @waza.translation }
      assert_no_errors :waza
    end

    assert_redirected_to waza_path(assigns(:waza))
  end

  test 'should show waza' do
    get :show, id: @waza
    assert_response :success
  end

  test 'should get edit' do
    get :edit, id: @waza
    assert_response :success
  end

  test 'should update waza' do
    put :update, id: @waza, waza: { description: @waza.description,
        name: @waza.name, translation: @waza.translation }
    assert_redirected_to waza_path(assigns(:waza))
  end

  test 'should destroy waza' do
    assert_difference('Waza.count', -1) do
      delete :destroy, id: @waza
    end

    assert_redirected_to wazas_path
  end
end
