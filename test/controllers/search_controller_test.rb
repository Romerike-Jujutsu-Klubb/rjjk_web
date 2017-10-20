# frozen_string_literal: true

require 'integration_test'

class SearchControllerTest < ActionDispatch::IntegrationTest
  test 'user query' do
    get '/search', params: { q: 'Uwe' }
    assert_response :success
  end

  test 'empty user query' do
    get '/search'
    assert_response :success
  end

  test 'admin query' do
    login :admin
    get '/search', params: { q: 'Uwe' }
    assert_response :success
  end

  test 'empty admin query' do
    login :admin
    get '/search'
    assert_response :success
  end
end
