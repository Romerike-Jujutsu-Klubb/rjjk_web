require File.dirname(__FILE__) + '/../test_helper'

class EventsControllerTest < ActionController::TestCase
  def setup
    login(:admin)
  end

  def test_should_get_index
    get :index
    assert_response :success
    assert_not_nil assigns(:events)
  end

  def test_should_get_new
    get :new
    assert_response :success
  end

  def test_should_create_event
    assert_difference('Event.count') do
      post :create, :event => {:name => 'Stuff', :start_at => '2012-02-18'}
      assert_no_errors :event
    end

    assert_redirected_to event_path(assigns(:event))
  end

  def test_should_show_event
    get :show, :id => events(:one).id
    assert_response :success
  end

  def test_should_get_edit
    get :edit, :id => events(:one).id
    assert_response :success
    assert_select '#event_start_at[value=?]', '2012-02-18 13:37'
  end

  def test_should_update_event
    put :update, :id => events(:one).id, :event => { }
    assert_redirected_to edit_event_path(assigns(:event))
  end

  def test_should_destroy_event
    assert_difference('Event.count', -1) do
      delete :destroy, :id => events(:one).id
    end
    assert_redirected_to events_path
  end
end
