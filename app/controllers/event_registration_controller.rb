# frozen_string_literal: true

class EventRegistrationController < ApplicationController
  before_action :authenticate_user, except: %i[create index new]
  before_action except: %i[create index new] do
    @event_invitee = EventInvitee.find(params[:id])

    admin_required if @event_invitee.user_id != current_user.id
  end

  def index
    @events = Event.upcoming.to_a
  end

  def show; end

  def new
    @event_invitee = EventInvitee.new(params[:event_invitee])
    @event_invitee.user_id = current_user.id if current_user
  end

  def create
    @event_invitee = EventInvitee.new(params[:event_invitee])
    @event_invitee.will_attend = true
    @event_invitee.user_id = current_user.id if current_user
    if @event_invitee.save
      redirect_to event_registration_path(@event_invitee.id)
    else
      render :new
    end
  end

  def accept
    if @event_invitee.update(will_attend: true)
      flash[:notice] = 'Du er påmeldt.'
      redirect_to event_registration_path(@event_invitee)
    else
      redirect_back fallback_location: root_path
    end
  end

  def decline
    if @event_invitee.update(will_attend: false)
      flash[:notice] = 'Du er avmeldt.'
      redirect_to event_registration_path(@event_invitee)
    else
      redirect_back fallback_location: root_path
    end
  end

  def will_work
    if @event_invitee.update(will_work: true)
      flash[:notice] = 'Du er påmeldt!'
      redirect_to event_registration_path(@event_invitee)
    else
      redirect_back fallback_location: root_path
    end
  end

  def will_not_work
    if @event_invitee.update(will_work: false)
      flash[:notice] = 'Du vil ikke jobbe på leiren.'
      redirect_to event_registration_path(@event_invitee)
    else
      redirect_back fallback_location: root_path
    end
  end
end
