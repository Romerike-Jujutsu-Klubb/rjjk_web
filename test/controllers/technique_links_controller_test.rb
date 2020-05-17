# frozen_string_literal: true

require 'controller_test'

class TechniqueLinksControllerTest < ActionController::TestCase
  setup do
    @technique_link = technique_links(:one)
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

  test 'should create technique_link' do
    assert_difference('TechniqueLink.count') do
      post :create, params: { technique_link: {
        linkable_type: @technique_link.linkable_type,
        linkable_id: @technique_link.linkable_id,
        title: @technique_link.title,
        url: 'https://a.new/url to somewhere',
      } }
    end

    assert_redirected_to TechniqueLink.last.linkable
  end

  test 'should show technique_link' do
    get :show, params: { id: @technique_link }
    assert_response :success
  end

  test 'should get edit' do
    get :edit, params: { id: @technique_link }
    assert_response :success
  end

  test 'should update technique_link' do
    put :update, params: { id: @technique_link, technique_link: {
      linkable_type: @technique_link.linkable_type,
      linkable_id: @technique_link.linkable_id,
      position: @technique_link.position,
      title: @technique_link.title,
      url: @technique_link.url,
    } }
    assert_redirected_to @technique_link.linkable
  end

  test 'should destroy technique_link' do
    assert_difference('TechniqueLink.count', -1) do
      delete :destroy, params: { id: @technique_link }
    end

    assert_redirected_to @controller.edit_polymorphic_path(@technique_link.linkable)
  end
end
