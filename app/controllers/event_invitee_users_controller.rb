# frozen_string_literal: true

class EventInviteeUsersController < ApplicationController
  before_action :authenticate_user, except: :index
  before_action except: :index do
    @event_invitee = EventInvitee.find(params[:id])

    admin_required if @event_invitee.user_id != current_user.id
  end

  def index
    @events = Event.upcoming.to_a
  end

  def show; end

  def accept
    if @event_invitee.update(will_attend: true)
      flash[:notice] = 'Du er påmeldt.'
      redirect_to event_invitee_user_path(@event_invitee)
    else
      redirect_back fallback_location: root_path
    end
  end

  def decline
    if @event_invitee.update(will_attend: false)
      flash[:notice] = 'Du er avmeldt.'
      redirect_to event_invitee_user_path(@event_invitee)
    else
      redirect_back fallback_location: root_path
    end
  end

  def will_work
    if @event_invitee.update(will_work: true)
      flash[:notice] = 'Du er påmeldt!'
      redirect_to event_invitee_user_path(@event_invitee)
    else
      redirect_back fallback_location: root_path
    end
  end

  def will_not_work
    if @event_invitee.update(will_work: false)
      flash[:notice] = 'Du vil ikke jobbe på leiren.'
      redirect_to event_invitee_user_path(@event_invitee)
    else
      redirect_back fallback_location: root_path
    end
  end
end
