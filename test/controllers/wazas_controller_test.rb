# frozen_string_literal: true

require 'controller_test'

class WazasControllerTest < ActionController::TestCase
  setup do
    @waza = wazas(:tsuki)
    login(:uwe)
  end

  test 'should get index' do
    get :index
    assert_response :success
  end

  test 'should get new' do
    get :new
    assert_response :success
  end

  test 'should create waza' do
    assert_difference('Waza.count') do
      post :create, params: { waza: { description: @waza.description, name: 'Super-punch',
                                      translation: @waza.translation } }
    end

    assert_redirected_to waza_path(Waza.last)
  end

  test 'should show waza' do
    get :show, params: { id: @waza }
    assert_response :success
  end

  test 'should get edit' do
    get :edit, params: { id: @waza }
    assert_response :success
  end

  test 'should update waza' do
    put :update, params: { id: @waza, waza: { description: @waza.description,
                                              name: @waza.name, translation: @waza.translation } }
    assert_redirected_to waza_path(@waza)
  end

  test 'should destroy waza' do
    assert_difference('Waza.count', -1) do
      delete :destroy, params: { id: @waza }
    end

    assert_redirected_to wazas_path
  end
end
