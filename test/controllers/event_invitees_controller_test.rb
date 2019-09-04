# frozen_string_literal: true

require 'controller_test'

class EventInviteesControllerTest < ActionController::TestCase
  setup do
    login :uwe
    @event_invitee = event_invitees(:one)
  end

  test 'should get index' do
    get :index
    assert_response :success
  end

  test 'should get new' do
    get :new, params: { event_invitee: { event_id: events(:one).id } }
    assert_response :success
  end

  test 'should create event_invitee' do
    assert_difference('EventInvitee.count') do
      post :create, params: { event_invitee: {
        user_id: id(:lars),
        address: @event_invitee.address,
        email: 'third_email',
        event_id: @event_invitee.event_id,
        name: @event_invitee.name,
        organization: @event_invitee.organization,
        payed: @event_invitee.payed,
        will_attend: @event_invitee.will_attend,
      } }
    end

    assert_redirected_to event_invitee_path(EventInvitee.last)
  end

  test 'should show event_invitee' do
    get :show, params: { id: @event_invitee }
    assert_response :success
  end

  test 'should get edit' do
    get :edit, params: { id: @event_invitee }
    assert_response :success
  end

  test 'should update event_invitee' do
    put :update, params: { id: @event_invitee, event_invitee: {
      user_id: id(:lars),
      address: @event_invitee.address,
      email: @event_invitee.email,
      event_id: @event_invitee.event_id,
      name: @event_invitee.name,
      organization: @event_invitee.organization,
      payed: @event_invitee.payed,
      will_attend: @event_invitee.will_attend,
    } }
    assert_redirected_to event_invitee_path(@event_invitee)
  end

  test 'should destroy event_invitee' do
    assert_difference('EventInvitee.count', -1) do
      delete :destroy, params: { id: @event_invitee }
    end

    assert_redirected_to event_invitees_path
  end
end
