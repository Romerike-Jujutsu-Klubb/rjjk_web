# frozen_string_literal: true

require 'test_helper'

class RanksControllerTest < ActionController::TestCase
  fixtures :ranks

  def setup
    @first_id = ranks(:kyu_5).id
    login(:lars)
  end

  def test_index
    get :index
    assert_response :success
    assert_template :index
  end

  def test_list
    get :index

    assert_response :success
    assert_template :index

    assert_not_nil assigns(:ranks)
  end

  def test_show
    get :show, params:{id: @first_id}

    assert_response :success
    assert_template 'show'

    assert_not_nil assigns(:rank)
    assert assigns(:rank).valid?
  end

  def test_new
    get :new

    assert_response :success
    assert_template 'new'

    assert_not_nil assigns(:rank)
  end

  def test_create
    num_ranks = Rank.count

    post :create, params:{rank: {
        group_id: groups(:panda).id, martial_art_id: martial_arts(:keiwaryu).id,
        name: '3.kyu', colour: 'grønt', position: -3, standard_months: 12
    }}
    assert_no_errors :rank
    assert_response :redirect
    assert_redirected_to action: :index

    assert_equal num_ranks + 1, Rank.count
  end

  def test_edit
    get :edit, params:{id: @first_id}

    assert_response :success
    assert_template 'edit'

    assert_not_nil assigns(:rank)
    assert assigns(:rank).valid?
  end

  def test_update
    post :update, params:{id: @first_id, rank: {name: '3.kyu'}}
    assert_response :redirect
    assert_redirected_to rank_path(assigns(:rank))
  end

  def test_destroy
    assert_nothing_raised { Rank.find(@first_id) }

    post :destroy, params:{id: @first_id}
    assert_response :redirect
    assert_redirected_to action: :index

    assert_raise(ActiveRecord::RecordNotFound) { Rank.find(@first_id) }
  end

  def test_pensum
    get :pensum
  end

  def test_pensum_for_beginner
    login :newbie
    get :pensum
  end
end
