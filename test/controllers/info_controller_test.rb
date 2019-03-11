# frozen_string_literal: true

require 'controller_test'

class InfoControllerTest < ActionController::TestCase
  def test_index
    login(:admin)
    get :index
    assert_response :success
  end

  def test_show
    get :show, params: { id: information_pages(:first).id }
    assert_response :success
  end

  test 'show with unknown utf8 title' do
    assert_raises ActiveRecord::RecordNotFound do
      get :show, params: { id: 'Nøkjelpersoner' }
    end
  end

  def test_new
    login(:admin)
    get :new
    assert_response :success
  end

  def test_create
    num_information_pages = InformationPage.count

    login(:admin)
    post :create, params: { information_page: { title: 'an article', public: true } }

    assert_response :redirect
    assert_redirected_to action: :show, id: InformationPage.find_by(title: 'an article')

    assert_equal num_information_pages + 1, InformationPage.count
  end

  def test_edit
    login(:admin)
    get :edit, params: { id: information_pages(:first).id }
    assert_response :success
  end

  def test_update
    login(:admin)
    post :update, params: { id: information_pages(:first).id, information_page: { title: 'an article' } }
    assert_response :redirect
    assert_redirected_to action: 'show', id: information_pages(:first).id
  end

  def test_destroy
    FrontPageSection.destroy_all
    information_page = information_pages(:first)

    login(:admin)
    delete :destroy, params: { id: information_page.id }
    assert_response :redirect
    assert_redirected_to controller: :news, action: :index

    assert_raise(ActiveRecord::RecordNotFound) do
      InformationPage.find(information_page.id)
    end
  end

  def test_destroy_fails_for_existing_front_page_section
    information_page = information_pages(:first)

    login(:admin)
    delete :destroy, params: { id: information_page.id }
    assert_response :success

    InformationPage.find(information_page.id)
  end

  def test_versjon
    get :versjon
  end
end
