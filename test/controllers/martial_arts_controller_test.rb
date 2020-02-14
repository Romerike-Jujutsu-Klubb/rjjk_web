# frozen_string_literal: true

require 'controller_test'

class MartialArtsControllerTest < ActionController::TestCase
  setup do
    @kwr = martial_arts(:keiwaryu)
    @first_id = @kwr.id
    login(:uwe)
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
    assert_difference(-> { MartialArt.count }) do
      post :create, params: { martial_art: { family: 'Karate', name: 'Wado Ryu' } }
    end
    assert_response :redirect
    assert_redirected_to action: :index
  end

  def test_copy
    assert_difference(-> { MartialArt.count }) { post :copy, params: { id: @first_id } }
    assert_response :redirect
    copy = MartialArt.last
    assert_redirected_to edit_martial_art_path(copy)
    assert_equal @kwr.curriculum_groups.count, copy.curriculum_groups.count
    assert_equal @kwr.curriculum_groups.map(&:ranks).map(&:count),
        copy.curriculum_groups.map(&:ranks).map(&:count)
    assert_equal @kwr.curriculum_groups.flat_map(&:ranks).map(&:basic_techniques).map(&:count),
        copy.curriculum_groups.flat_map(&:ranks).map(&:basic_techniques).map(&:count)
    assert_equal @kwr.curriculum_groups.flat_map(&:ranks).map(&:technique_applications).map(&:count),
        copy.curriculum_groups.flat_map(&:ranks).map(&:technique_applications).map(&:count)
  end

  def test_edit
    get :edit, params: { id: @first_id }
    assert_response :success
  end

  def test_update
    post :update, params: { id: @first_id, martial_art: { name: 'Hapkido' } }
    assert_response :redirect
    assert_redirected_to action: :show, id: @first_id
  end

  def test_destroy
    assert_nothing_raised { MartialArt.find(@first_id) }
    groups(:panda).destroy!
    groups(:tiger).destroy!
    groups(:voksne).destroy!
    groups(:closed).destroy!

    post :destroy, params: { id: @first_id }

    assert_response :redirect
    assert_redirected_to action: :index

    assert_raise(ActiveRecord::RecordNotFound) { MartialArt.find(@first_id) }
  end
end
