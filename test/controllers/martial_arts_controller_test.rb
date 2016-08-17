# frozen_string_literal: true
require 'test_helper'

class MartialArtsControllerTest < ActionController::TestCase
  fixtures :martial_arts

  def setup
    @first_id = martial_arts(:keiwaryu).id
    login(:admin)
  end

  def test_index
    get :index
    assert_response :success
    assert_template 'list'
  end

  def test_list
    get :index

    assert_response :success
    assert_template 'list'

    assert_not_nil assigns(:martial_arts)
  end

  def test_show
    get :show, id: @first_id

    assert_response :success
    assert_template 'show'

    assert_not_nil assigns(:martial_art)
    assert assigns(:martial_art).valid?
  end

  def test_new
    get :new

    assert_response :success
    assert_template 'new'

    assert_not_nil assigns(:martial_art)
  end

  def test_create
    num_martial_arts = MartialArt.count

    post :create, martial_art: { family: 'Karate', name: 'Wado Ryu' }
    assert_no_errors :martial_art
    assert_response :redirect
    assert_redirected_to action: 'list'

    assert_equal num_martial_arts + 1, MartialArt.count
  end

  def test_edit
    get :edit, id: @first_id

    assert_response :success
    assert_template 'edit'

    assert_not_nil assigns(:martial_art)
    assert assigns(:martial_art).valid?
  end

  def test_update
    post :update, id: @first_id, martial_art: {}
    assert_response :redirect
    assert_redirected_to action: 'show', id: @first_id
  end

  def test_destroy
    assert_nothing_raised do
      MartialArt.find(@first_id)
    end

    post :destroy, id: @first_id
    assert_response :redirect
    assert_redirected_to action: 'list'

    assert_raise(ActiveRecord::RecordNotFound) do
      MartialArt.find(@first_id)
    end
  end
end
