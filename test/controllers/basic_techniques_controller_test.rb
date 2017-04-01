# frozen_string_literal: true

require 'test_helper'

class BasicTechniquesControllerTest < ActionController::TestCase
  setup do
    @basic_technique = basic_techniques(:osoto_otoshi)
    login(:lars)
  end

  test 'should get index' do
    get :index
    assert_response :success
    assert_not_nil assigns(:basic_techniques)
  end

  test 'should get new' do
    get :new
    assert_response :success
  end

  test 'should create basic_technique' do
    assert_difference('BasicTechnique.count') do
      post :create, params:{basic_technique: {
          description: @basic_technique.description,
          name: @basic_technique.name + ' 2', rank_id: @basic_technique.rank_id,
          translation: @basic_technique.translation,
          waza_id: @basic_technique.waza_id
      }}
    end

    assert_redirected_to basic_technique_path(assigns(:basic_technique))
  end

  test 'should show basic_technique' do
    get :show, params:{id: @basic_technique}
    assert_response :success
  end

  test 'should get edit' do
    get :edit, params:{id: @basic_technique}
    assert_response :success
  end

  test 'should update basic_technique' do
    put :update, params:{id: @basic_technique, basic_technique: {
        description: @basic_technique.description,
        name: @basic_technique.name,
        rank_id: @basic_technique.rank_id,
        translation: @basic_technique.translation,
        waza_id: @basic_technique.waza_id,
    }}
    assert_redirected_to basic_technique_path(assigns(:basic_technique))
  end

  test 'should destroy basic_technique' do
    assert_difference('BasicTechnique.count', -1) do
      delete :destroy, params:{id: @basic_technique}
    end

    assert_redirected_to basic_techniques_path
  end
end
