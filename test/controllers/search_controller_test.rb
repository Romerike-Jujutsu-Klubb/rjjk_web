require 'test_helper'

class SearchControllerTest < ActionController::TestCase
  test 'user query' do
    get :index, q: 'Uwe'
    assert_response :success
  end

  test 'empty user query' do
    get :index
    assert_response :success
  end

  test 'admin query' do
    login :admin
    get :index, q: 'Uwe'
    assert_response :success
  end

  test 'empty admin query' do
    login :admin
    get :index
    assert_response :success
  end

end
