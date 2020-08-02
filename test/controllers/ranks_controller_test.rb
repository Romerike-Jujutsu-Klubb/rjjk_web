# frozen_string_literal: true

require 'controller_test'

class RanksControllerTest < ActionController::TestCase
  def setup
    @first_id = ranks(:kyu_5).id
    login(:lars)
  end

  def test_index
    get :index
    assert_response :success
  end

  def test_list
    get :index
    assert_response :success
  end

  def test_show
    get :show, params: { id: @first_id }
    assert_response :success
  end

  def test_card
    get :card, params: { id: @first_id }
    assert_response :success
  end

  def test_card_pdf
    get :card_pdf, params: { id: @first_id }
    assert_response :success
  end

  def test_new
    get :new
    assert_response :success
  end

  def test_create
    num_ranks = Rank.count

    post :create, params: { rank: {
      curriculum_group_id: groups(:panda).id, name: '3.kyu', colour: 'grønt', position: -3,
      standard_months: 12
    } }
    assert_response :redirect
    assert_redirected_to action: :index
    assert_equal num_ranks + 1, Rank.count
  end

  def test_edit
    get :edit, params: { id: @first_id }
    assert_response :success
  end

  def test_update
    post :update, params: { id: @first_id, rank: { name: '3.kyu' } }
    assert_response :redirect
    assert_redirected_to rank_path(@first_id)
  end

  def test_destroy
    assert_nothing_raised { Rank.find(@first_id) }

    post :destroy, params: { id: @first_id }
    assert_response :redirect
    assert_redirected_to action: :index

    assert_raise(ActiveRecord::RecordNotFound) { Rank.find(@first_id) }
  end
end
