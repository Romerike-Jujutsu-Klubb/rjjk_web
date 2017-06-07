# frozen_string_literal: true

require 'test_helper'

class BasicTechniqueLinksControllerTest < ActionController::TestCase
  setup do
    @basic_technique_link = basic_technique_links(:one)
    login(:admin)
  end

  test 'should get index' do
    get :index
    assert_response :success
    assert_not_nil assigns(:basic_technique_links)
  end

  test 'should get new' do
    get :new
    assert_response :success
  end

  test 'should create basic_technique_link' do
    assert_difference('BasicTechniqueLink.count') do
      post :create, params: { basic_technique_link: {
          basic_technique_id: @basic_technique_link.basic_technique_id,
          position: @basic_technique_link.position + 2,
          title: @basic_technique_link.title,
          url: 'a new url to somewhere',
      } }
      assert_no_errors :basic_technique_link
    end

    assert_redirected_to basic_technique_link_path(assigns(:basic_technique_link))
  end

  test 'should show basic_technique_link' do
    get :show, params: { id: @basic_technique_link }
    assert_response :success
  end

  test 'should get edit' do
    get :edit, params: { id: @basic_technique_link }
    assert_response :success
  end

  test 'should update basic_technique_link' do
    put :update, params: { id: @basic_technique_link, basic_technique_link: {
        basic_technique_id: @basic_technique_link.basic_technique_id,
        position: @basic_technique_link.position,
        title: @basic_technique_link.title,
        url: @basic_technique_link.url,
    } }
    assert_redirected_to basic_technique_link_path(assigns(:basic_technique_link))
  end

  test 'should destroy basic_technique_link' do
    assert_difference('BasicTechniqueLink.count', -1) do
      delete :destroy, params: { id: @basic_technique_link }
      assert_no_errors :basic_technique_link
    end

    assert_redirected_to basic_technique_links_path
  end
end
