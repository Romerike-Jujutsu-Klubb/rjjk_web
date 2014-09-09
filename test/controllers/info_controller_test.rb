require 'test_helper'

class InfoControllerTest < ActionController::TestCase
  fixtures :users, :information_pages

  def test_index
    get :index
    assert_response :success
    assert_template :index
  end

  def test_list
    get :index

    assert_response :success
    assert_template :index

    assert_not_nil assigns(:information_pages)
  end

  def test_show
    get :show, :id => information_pages(:first).id

    assert_response :success
    assert_template 'show'

    assert_not_nil assigns(:information_page)
    assert assigns(:information_page).valid?
  end

  def test_new
    login(:admin)
    get :new

    assert_response :success
    assert_template 'new'

    assert_not_nil assigns(:information_page)
  end

  def test_create
    num_information_pages = InformationPage.count

    login(:admin)
    post :create, :information_page => {:title => 'an article'}
    assert_no_errors :information_page

    assert_response :redirect
    assert_redirected_to :action => :show, :id => InformationPage.find_by_title('an article')

    assert_equal num_information_pages + 1, InformationPage.count
  end

  def test_edit
    login(:admin)
    get :edit, id: information_pages(:first).id

    assert_response :success
    assert_template 'edit'

    assert_not_nil assigns(:information_page)
    assert assigns(:information_page).valid?
  end

  def test_update
    login(:admin)
    post :update, id: information_pages(:first).id, information_page: {}
    assert_response :redirect
    assert_redirected_to action: 'show', id: information_pages(:first).id
  end

  def test_destroy
    information_page = information_pages(:first)
    assert_not_nil information_page

    login(:admin)
    post :destroy, id: information_page.id
    assert_response :redirect
    assert_redirected_to controller: :news, action: :index

    assert_raise(ActiveRecord::RecordNotFound) do
      InformationPage.find(information_page.id)
    end
  end
end
