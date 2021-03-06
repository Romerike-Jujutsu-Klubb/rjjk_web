# frozen_string_literal: true

require 'controller_test'

class EventsControllerTest < ActionController::TestCase
  setup { login(:uwe) }

  def test_should_get_index
    get :index
    assert_response :success
  end

  def test_should_get_new
    get :new
    assert_response :success
  end

  def test_should_create_event
    assert_difference('Event.count') do
      post :create, params: { event: { name: 'Stuff', start_at: '2012-02-18' } }
    end

    assert_redirected_to edit_event_path(Event.last)
  end

  def test_should_show_event
    get :show, params: { id: id(:one) }
    assert_response :success
  end

  test 'should show event anonymously' do
    logout
    get :show, params: { id: id(:one) }
    assert_response :success
  end

  test 'should get event preview' do
    get :preview, params: { id: id(:one) }
    assert_response :success
  end

  def test_should_get_edit
    get :edit, params: { id: id(:one) }
    assert_response :success
    assert_equal '2017-08-19 13:37', css_select('#event_start_at')[0]['value']
  end

  def test_should_update_event
    event = events(:one)
    put :update, params: { id: event.id, event: { name: 'Stuff' },
                           group: { id: [id(:panda), id(:tiger), id(:voksne)] } }
    assert_redirected_to edit_event_path(event)
  end

  def test_should_destroy_event
    assert_difference('Event.count', -1) do
      delete :destroy, params: { id: id(:one) }
    end
    assert_redirected_to events_path
  end

  def test_calendar
    get :calendar
  end

  test 'invite example' do
    login
    post :invite, params: { id: id(:one), example: '' }
  end

  def test_accept
    login :oldie
    patch :accept, params: { id: id(:one) }
  end

  def test_decline
    login :oldie
    patch :decline, params: { id: id(:one) }
  end
end
