# frozen_string_literal: true

class EventInviteeUsersController < ApplicationController
  before_action do
    @event_invitee = EventInvitee.find(params[:id])

    token = params[:security_token]
    if @event_invitee.security_token_matches(token)
      cookies.encrypted["ei_#{@event_invitee.id}"] = token
    elsif cookies["ei_#{@event_invitee.id}"] != @event_invitee.security_token
      redirect_to @event_invitee.event, alert: I18n.t(:access_denied, locale: @event_invitee.locale)
    end
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
      flash[:notice] = 'Du vill ikke jobbe på leiren.'
      redirect_to event_invitee_user_path(@event_invitee)
    else
      redirect_back fallback_location: root_path
    end
  end
end
