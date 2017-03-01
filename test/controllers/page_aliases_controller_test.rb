# frozen_string_literal: true
require 'test_helper'

class PageAliasesControllerTest < ActionController::TestCase
  setup do
    @page_alias = page_aliases(:one)
    login :admin
  end

  test 'should get index' do
    get :index
    assert_response :success
    assert_not_nil assigns(:page_aliases)
  end

  test 'should get new' do
    get :new
    assert_response :success
  end

  test 'should create page_alias' do
    assert_difference('PageAlias.count') do
      post :create, params:{page_alias: { new_path: @page_alias.new_path, old_path: '/someother_path' }}
      assert_no_errors :page_alias
    end

    assert_redirected_to page_alias_path(assigns(:page_alias))
  end

  test 'should show page_alias' do
    get :show, params:{id: @page_alias}
    assert_response :success
  end

  test 'should get edit' do
    get :edit, params:{id: @page_alias}
    assert_response :success
  end

  test 'should update page_alias' do
    put :update, params:{id: @page_alias, page_alias: {
        new_path: @page_alias.new_path, old_path: @page_alias.old_path
    }}
    assert_redirected_to page_alias_path(assigns(:page_alias))
  end

  test 'should destroy page_alias' do
    assert_difference('PageAlias.count', -1) do
      delete :destroy, params:{id: @page_alias}
    end

    assert_redirected_to page_aliases_path
  end
end
