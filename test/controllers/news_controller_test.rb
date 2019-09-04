# frozen_string_literal: true

require 'controller_test'

class NewsControllerTest < ActionController::TestCase
  def test_index
    get :index
    assert_response :success
  end

  def test_list
    get :index
    assert_response :success
  end

  def test_show
    get :show, params: { id: news_items(:first).id }
    assert_response :success
  end

  def test_new
    login(:uwe)
    get :new
    assert_response :success
  end

  def test_create
    num_news_items = NewsItem.count

    login(:uwe)
    post :create, params: { news_item: { title: 'another news item' } }

    assert_response :redirect
    assert_redirected_to action: 'list'

    assert_equal num_news_items + 1, NewsItem.count
  end

  def test_edit
    login(:uwe)
    get :edit, params: { id: news_items(:first).id }

    assert_response :success
    assert_select '#news_item_publish_at[value="2007-07-12 13:37"]'
    assert_equal '2199-12-31 23:59', css_select('#news_item_expire_at')[0]['value']
  end

  def test_update
    login(:uwe)
    post :update, params: { id: news_items(:first).id, news_item: { title: 'another news item' } }
    assert_response :redirect
    assert_redirected_to action: :show, id: news_items(:first).id
  end

  def test_expire
    n = news_items(:first)
    login(:uwe)
    post :expire, params: { id: n.id }
    assert_response :redirect
    assert_redirected_to action: :index
    n.reload
    assert_equal NewsItem::PublicationState::EXPIRED, n.publication_state
  end

  def test_destroy
    n = news_items(:first)
    assert_not_nil n

    login(:uwe)
    post :destroy, params: { id: n.id }
    assert_response :redirect
    assert_redirected_to action: :index

    assert_raise(ActiveRecord::RecordNotFound) do
      NewsItem.find(n.id)
    end
  end
end
