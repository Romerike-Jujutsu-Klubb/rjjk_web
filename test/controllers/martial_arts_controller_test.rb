# frozen_string_literal: true

require 'controller_test'

class MartialArtsControllerTest < ActionController::TestCase
  def setup
    @first_id = martial_arts(:keiwaryu).id
    login(:admin)
  end

  def test_index
    get :index
    assert_response :success
  end

  def test_show
    get :show, params: { id: @first_id }
    assert_response :success
  end

  def test_new
    get :new
    assert_response :success
  end

  def test_create
    num_martial_arts = MartialArt.count

    post :create, params: { martial_art: { family: 'Karate', name: 'Wado Ryu' } }
    assert_response :redirect
    assert_redirected_to action: :index
    assert_equal num_martial_arts + 1, MartialArt.count
  end

  def test_edit
    get :edit, params: { id: @first_id }
    assert_response :success
  end

  def test_update
    post :update, params: { id: @first_id, martial_art: { name: 'Hapkido' } }
    assert_response :redirect
    assert_redirected_to action: 'show', id: @first_id
  end

  def test_destroy
    assert_nothing_raised do
      MartialArt.find(@first_id)
    end

    post :destroy, params: { id: @first_id }
    assert_response :redirect
    assert_redirected_to action: :index

    assert_raise(ActiveRecord::RecordNotFound) do
      MartialArt.find(@first_id)
    end
  end
end
