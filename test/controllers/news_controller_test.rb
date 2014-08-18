require File.dirname(__FILE__) + '/../test_helper'
require 'news_controller'

# Re-raise errors caught by the controller.
class NewsController; def rescue_action(e) raise e end; end

class NewsControllerTest < ActionController::TestCase
  fixtures :users, :news_items

  def setup
    @controller = NewsController.new
    @request    = ActionController::TestRequest.new
    @response   = ActionController::TestResponse.new
  end

  def test_index
    get :index
    assert_response :success
    assert_template 'news/index'
    assert_template layout: 'dark_ritual'
  end

  def test_list
    get :index

    assert_response :success
    assert_template 'index'

    assert_not_nil assigns(:news_items)
  end

  def test_show
    get :show, :id => news_items(:first).id

    assert_response :success
    assert_template 'show'

    assert_not_nil assigns(:news_item)
    assert assigns(:news_item).valid?
  end

  def test_new
    login(:admin)
    get :new

    assert_response :success
    assert_template 'new'

    assert_not_nil assigns(:news_item)
  end

  def test_create
    num_news_items = NewsItem.count

    login(:admin)
    post :create, :news_item => {:title => 'another news item'}

    assert_response :redirect
    assert_redirected_to :action => 'list'

    assert_equal num_news_items + 1, NewsItem.count
  end

  def test_edit
    login(:admin)
    get :edit, id: news_items(:first).id

    assert_response :success
    assert_template 'edit'

    assert_not_nil assigns(:news_item)
    assert assigns(:news_item).valid?

    assert_select '#news_item_publish_at[value=?]', '2007-07-12 13:37'
    assert_equal '2199-12-31 23:59', css_select('#news_item_expire_at')[0]['value']
  end

  def test_update
    login(:admin)
    post :update, id: news_items(:first).id, news_item: {}
    assert_response :redirect
    assert_redirected_to action: :show, id: news_items(:first).id
  end

  def test_destroy
    n = news_items(:first)
    assert_not_nil n

    login(:admin)
    post :destroy, id: n.id
    assert_response :redirect
    assert_redirected_to action: :index

    assert_raise(ActiveRecord::RecordNotFound) do
      NewsItem.find(n.id)
    end
  end
end
