# frozen_string_literal: true

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
      post :create, params:{ event: { name: 'Stuff', start_at: '2012-02-18' } }
      assert_no_errors :event
    end

    assert_redirected_to event_path(assigns(:event))
  end

  def test_should_show_event
    get :show, params:{ id: events(:one).id }
    assert_response :success
  end

  def test_should_get_edit
    get :edit, params:{ id: events(:one).id }
    assert_response :success
    assert_equal '2017-08-19 13:37', css_select('#event_start_at')[0]['value']
  end

  def test_should_update_event
    put :update, params:{ id: events(:one).id, event: { name: 'Stuff' } }
    assert_redirected_to edit_event_path(assigns(:event))
  end

  def test_should_destroy_event
    assert_difference('Event.count', -1) do
      delete :destroy, params:{ id: events(:one).id }
    end
    assert_redirected_to events_path
  end

  def test_calendar
    get :calendar
  end
end
